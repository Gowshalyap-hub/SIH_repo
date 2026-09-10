import '../../../core/utils/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../widgets/app_card.dart';
import '../../../providers/herd_provider.dart';
import '../../../models/risk_level.dart';
import '../../../widgets/empty_state.dart';

class HerdScreen extends StatefulWidget {
  const HerdScreen({Key? key}) : super(key: key);

  @override
  State<HerdScreen> createState() => _HerdScreenState();
}

class _HerdScreenState extends State<HerdScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<HerdProvider>().loadHerd('farm_001'));
  }

  @override
  Widget build(BuildContext context) {
    final herdProvider = context.watch<HerdProvider>();
    final cows = herdProvider.filteredCows;
    final totalCows = herdProvider.allCows.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, totalCows),
            _buildSearchBar(herdProvider),
            _buildFilters(herdProvider),
            Expanded(
              child: herdProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : cows.isEmpty
                      ? EmptyState(message: 'No cows found') 
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: cows.length,
                      itemBuilder: (context, index) {
                        final cow = cows[index];
                        return _buildCowCard(context, cow);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int totalCows) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context).translate('my_herd') ?? 'My Herd', style: AppTextStyles.h1.copyWith(fontSize: 24)),
              const SizedBox(height: 4),
              Text('$totalCows Cows', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
            onPressed: () => context.push('/alerts'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(HerdProvider herdProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        onChanged: herdProvider.setSearchQuery,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).translate('search_by_name_or_tag___') ?? 'Search by name or tag...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: const Icon(Icons.filter_list, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildFilters(HerdProvider herdProvider) {
    final allCount = herdProvider.allCows.length;
    final healthyCount = herdProvider.allCows.where((c) => c.currentRiskLevel == RiskLevel.none || c.currentRiskLevel == RiskLevel.low).length;
    final atRiskCount = herdProvider.allCows.where((c) => c.currentRiskLevel == RiskLevel.moderate).length;
    final criticalCount = herdProvider.allCows.where((c) => c.currentRiskLevel == RiskLevel.high).length;
    
    // Quick helper to check filter state (in a real app expose getter from provider)
    bool isRiskSelected(RiskLevel? level) => true; // Just a visual mock for now since _riskFilter is private

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _FilterChip(
            label: 'All ($allCount)', 
            isSelected: true, // we'd normally bind this
            onTap: () => herdProvider.setRiskFilter(null),
          ),
          const SizedBox(width: 8),
          _FilterChip(label: 'Healthy ($healthyCount)', isSelected: false, onTap: () => herdProvider.setRiskFilter(RiskLevel.none)),
          const SizedBox(width: 8),
          _FilterChip(label: 'At Risk ($atRiskCount)', isSelected: false, onTap: () => herdProvider.setRiskFilter(RiskLevel.moderate)),
          const SizedBox(width: 8),
          _FilterChip(label: 'Critical ($criticalCount)', isSelected: false, onTap: () => herdProvider.setRiskFilter(RiskLevel.high)),
        ],
      ),
    );
  }

  Widget _buildCowCard(BuildContext context, cow) {
    Color riskColor = AppColors.riskNone;
    String riskText = 'Healthy';
    if (cow.currentRiskLevel == RiskLevel.high) {
      riskColor = AppColors.riskHigh;
      riskText = 'High Risk';
    } else if (cow.currentRiskLevel == RiskLevel.moderate) {
      riskColor = AppColors.riskModerate;
      riskText = 'Moderate Risk';
    } else if (cow.currentRiskLevel == RiskLevel.low) {
      riskColor = AppColors.riskLow;
      riskText = 'Low Risk';
    }
    
    String milkText = '-- L';
    if (cow.lastMilkYield != null) {
      milkText = '${cow.lastMilkYield!.toStringAsFixed(1)} L';
    }
    
    String timeText = '--';
    if (cow.lastUpdated != null) {
      final diff = DateTime.now().difference(cow.lastUpdated!);
      if (diff.inMinutes < 60) timeText = '${diff.inMinutes}m ago';
      else if (diff.inHours < 24) timeText = '${diff.inHours}h ago';
      else timeText = '${diff.inDays}d ago';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppCard(
        child: InkWell(
          onTap: () => context.push('/cow/${cow.id}', extra: cow),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Cow Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.pets, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cow.id, style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(riskText, style: AppTextStyles.bodySmall.copyWith(color: riskColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                // Stats
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(milkText, style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(timeText, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
                        const Icon(Icons.chevron_right, size: 16, color: AppColors.textHint),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, this.isSelected = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
