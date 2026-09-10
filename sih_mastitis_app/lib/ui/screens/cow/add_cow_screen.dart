import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/app_localizations.dart';
import '../../../models/cow.dart';
import '../../../models/risk_level.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/herd_provider.dart';
import '../../../services/api/api_cow_service.dart';

class AddCowScreen extends StatefulWidget {
  const AddCowScreen({Key? key}) : super(key: key);

  @override
  State<AddCowScreen> createState() => _AddCowScreenState();
}

class _AddCowScreenState extends State<AddCowScreen> {
  final _tagController = TextEditingController();
  final _breedController = TextEditingController();
  final _dobController = TextEditingController();
  final _lactationController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSaving = false;
  String? _selectedImagePath;

  Future<void> _saveCow() async {
    final tag = _tagController.text.trim();
    if (tag.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).translate('tag_number_is_required'))));
      return;
    }
    
    final auth = context.read<AuthProvider>();
    final farmId = auth.currentUser?.farmId ?? 'FARM001';
    final service = ApiCowService();
    
    // 1. Immediately create Cow locally
    final newCow = Cow(
      id: tag,
      farmId: farmId,
      rfid: 'RFID_$tag',
      tagNumber: tag,
      dateOfBirth: _dobController.text.isNotEmpty ? DateTime.tryParse(_dobController.text) ?? DateTime.now() : DateTime.now(),
      breed: _breedController.text,
      currentRiskLevel: RiskLevel.none,
      lactationNumber: int.tryParse(_lactationController.text),
      notes: _notesController.text,
      photoPath: _selectedImagePath,
    );

    // 2. Add to HerdProvider
    context.read<HerdProvider>().addCowLocal(newCow);

    // 3. Fire-and-forget background sync (DO NOT AWAIT, ignore errors)
    service.createCow({
      'id': tag,
      'rfid': 'RFID_$tag',
      'breed': _breedController.text,
      'dob': _dobController.text.isNotEmpty ? _dobController.text : DateTime.now().toIso8601String().split('T')[0],
      'lactation_number': int.tryParse(_lactationController.text),
      'notes': _notesController.text,
      'photo_path': _selectedImagePath,
    }).catchError((_) => newCow);

    // 4. Immediately Pop and Show Success
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).translate('cow_added_successfully_'))));
      context.pop();
    }
  }

  @override
  void dispose() {
    _tagController.dispose();
    _breedController.dispose();
    _dobController.dispose();
    _lactationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('add_new_cow')),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppLocalizations.of(context).translate('register_a_new_cow_to_start_mo') ?? 'Register a new cow to start monitoring.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            
            // Upload Photo
            GestureDetector(
              onTap: () async {
                final source = await showModalBottomSheet<ImageSource>(
                  context: context,
                  builder: (context) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: Text(AppLocalizations.of(context).translate('take_photo') ?? 'Take Photo'),
                          onTap: () => Navigator.pop(context, ImageSource.camera),
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: Text(AppLocalizations.of(context).translate('choose_from_gallery') ?? 'Choose from Gallery'),
                          onTap: () => Navigator.pop(context, ImageSource.gallery),
                        ),
                      ],
                    ),
                  ),
                );

                if (source != null) {
                  try {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: source);
                    if (pickedFile != null) {
                      setState(() {
                        _selectedImagePath = pickedFile.path;
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context).translate('permission_denied_or_unavailab') ?? 'Permission denied or unavailable.')),
                      );
                    }
                  }
                }
              },
              child: Center(
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                    image: _selectedImagePath != null 
                      ? DecorationImage(
                          image: FileImage(File(_selectedImagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                  ),
                  child: _selectedImagePath == null 
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 32),
                          const SizedBox(height: 8),
                          Text(AppLocalizations.of(context).translate('upload_photo'), style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                        ],
                      )
                    : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            AppTextField(label: AppLocalizations.of(context).translate('tag_number__') ?? 'Tag Number *', hintText: AppLocalizations.of(context).translate('e_g__ind_0427') ?? 'e.g. IND-0427', controller: _tagController),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: AppTextField(label: AppLocalizations.of(context).translate('breed') ?? 'Breed', hintText: AppLocalizations.of(context).translate('gir') ?? 'Gir', controller: _breedController)),
                const SizedBox(width: 16),
                Expanded(child: AppTextField(label: AppLocalizations.of(context).translate('birth_date') ?? 'Birth Date', hintText: AppLocalizations.of(context).translate('yyyy_mm_dd') ?? 'yyyy-mm-dd', controller: _dobController)),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(label: AppLocalizations.of(context).translate('lactation_number') ?? 'Lactation Number', hintText: AppLocalizations.of(context).translate('1') ?? '1', controller: _lactationController, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            AppTextField(label: AppLocalizations.of(context).translate('notes__optional_') ?? 'Notes (optional)', hintText: AppLocalizations.of(context).translate('any_health_notes___') ?? 'Any health notes...', maxLines: 3, controller: _notesController),
            
            const SizedBox(height: 32),
            _isSaving 
              ? const Center(child: CircularProgressIndicator()) 
              : AppButton(text: AppLocalizations.of(context).translate('save_cow'), onPressed: _saveCow),
          ],
        ),
      ),
    );
  }
}
