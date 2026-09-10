import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/app_localizations.dart';
import '../../../providers/farm_provider.dart';
import '../../../providers/herd_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../models/farm.dart';

class FarmProfileScreen extends StatefulWidget {
  const FarmProfileScreen({Key? key}) : super(key: key);

  @override
  State<FarmProfileScreen> createState() => _FarmProfileScreenState();
}

class _FarmProfileScreenState extends State<FarmProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _vetNameController;
  late TextEditingController _vetPhoneController;
  late TextEditingController _vetEmailController;
  late TextEditingController _detailsController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final farmProvider = context.read<FarmProvider>();
      if (farmProvider.currentFarm == null) {
        farmProvider.loadFarm('demo_owner_id').then((_) {
          if (mounted) {
            final farm = farmProvider.currentFarm;
            _nameController.text = farm?.name ?? '';
            _locationController.text = farm?.location ?? '';
            _vetNameController.text = farm?.vetName ?? '';
            _vetPhoneController.text = farm?.vetPhone ?? '';
            _vetEmailController.text = farm?.vetEmail ?? '';
            _detailsController.text = farm?.additionalDetails ?? '';
          }
        });
      }
    });
    
    final farm = context.read<FarmProvider>().currentFarm;
    _nameController = TextEditingController(text: farm?.name ?? 'MastiQ Dairy Farm');
    _locationController = TextEditingController(text: farm?.location ?? 'Tamil Nadu');
    _vetNameController = TextEditingController(text: farm?.vetName ?? '');
    _vetPhoneController = TextEditingController(text: farm?.vetPhone ?? '');
    _vetEmailController = TextEditingController(text: farm?.vetEmail ?? '');
    _detailsController = TextEditingController(text: farm?.additionalDetails ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _vetNameController.dispose();
    _vetPhoneController.dispose();
    _vetEmailController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final provider = context.read<FarmProvider>();
    final farm = provider.currentFarm;
    if (farm == null) return;

    final updatedFarm = Farm(
      id: farm.id,
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      ownerId: farm.ownerId,
      vetName: _vetNameController.text.trim(),
      vetPhone: _vetPhoneController.text.trim(),
      vetEmail: _vetEmailController.text.trim(),
      additionalDetails: _detailsController.text.trim(),
    );

    provider.updateFarm(updatedFarm).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('farm_updated_successfully') ?? 'Farm profile updated')),
        );
      }
    });
  }

  Future<void> _contactVet() async {
    final phone = _vetPhoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate('no_veterinarian_phone_configured_'))),
      );
      return;
    }
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: <String, String>{
        'body': 'Farm MastiQ Report:\nPlease review the latest herd health status.',
      },
    );
    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        final Uri telUri = Uri(scheme: 'tel', path: phone);
        if (await canLaunchUrl(telUri)) {
          await launchUrl(telUri);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('could_not_open_contact_app_'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<FarmProvider>();
    final herdProvider = context.watch<HerdProvider>();
    final isLoading = provider.isLoading;
    
    final breeds = herdProvider.allCows.map((c) => c.breed).toSet().join(', ');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.translate('farm_profile') ?? 'Farm Profile'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: isLoading ? null : _saveChanges,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(loc.translate('general_info') ?? 'General Information'),
                  _buildTextField(_nameController, loc.translate('farm_name') ?? 'Farm Name', Icons.home),
                  const SizedBox(height: 12),
                  _buildTextField(_locationController, loc.translate('location') ?? 'Location', Icons.location_on),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle(loc.translate('herd_summary') ?? 'Herd Summary'),
                  _buildStatTile(Icons.pets, loc.translate('total_cows') ?? 'Total Cows', herdProvider.allCows.length.toString()),
                  _buildStatTile(Icons.category, loc.translate('cow_breeds') ?? 'Cow Breeds', breeds.isEmpty ? '--' : breeds),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle(loc.translate('veterinarian_contact') ?? 'Veterinarian Contact'),
                  _buildTextField(_vetNameController, loc.translate('vet_name') ?? 'Doctor Name', Icons.person),
                  const SizedBox(height: 12),
                  _buildTextField(_vetPhoneController, loc.translate('vet_phone') ?? 'Phone Number', Icons.phone, keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _buildTextField(_vetEmailController, loc.translate('vet_email') ?? 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _contactVet,
                      icon: const Icon(Icons.send),
                      label: Text(loc.translate('contact_veterinarian') ?? 'Contact Veterinarian'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle(loc.translate('additional_details') ?? 'Additional Details'),
                  _buildTextField(_detailsController, loc.translate('notes') ?? 'Notes', Icons.notes, maxLines: 3),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppTextStyles.h3),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildStatTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Text(label, style: AppTextStyles.bodyLarge),
          const Spacer(),
          Text(value, style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}
