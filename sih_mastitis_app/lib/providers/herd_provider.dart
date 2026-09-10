import 'package:flutter/material.dart';
import '../../models/cow.dart';
import '../../models/risk_level.dart';
import '../../models/milk_reading.dart';
import '../../services/api/api_cow_service.dart';

class HerdProvider extends ChangeNotifier {
  final ApiCowService _cowService = ApiCowService();
  
  List<Cow> _cows = [];
  bool _isLoading = false;
  String? _error;
  RiskLevel? _riskFilter;
  String _searchQuery = '';

  List<Cow> get allCows => _cows;
  List<Cow> get filteredCows {
    return _cows.where((cow) {
      bool matchesRisk = _riskFilter == null || cow.currentRiskLevel == _riskFilter;
      bool matchesSearch = cow.id.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                           cow.rfid.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesRisk && matchesSearch;
    }).toList();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHerd(String farmId) async {
    if (_cows.isNotEmpty) return; // PROTOTYPE: keep local data`n    `n    // SEED INITIAL DEMO DATA`n    _cows = [`n      Cow(`n        id: "04445",`n        farmId: farmId,`n        rfid: "RFID_04445",`n        tagNumber: "04445",`n        dateOfBirth: DateTime.now().subtract(const Duration(days: 4 * 365)),`n        breed: "Gir",`n        currentRiskLevel: RiskLevel.low,`n        lastMilkYield: 8.5,`n        lactationNumber: 2,`n        notes: "Lakshmi - Healthy",`n        lastUpdated: DateTime.now(),`n      ),`n      Cow(`n        id: "05555",`n        farmId: farmId,`n        rfid: "RFID_05555",`n        tagNumber: "05555",`n        dateOfBirth: DateTime.now().subtract(const Duration(days: 5 * 365)),`n        breed: "Sahiwal",`n        currentRiskLevel: RiskLevel.moderate,`n        lastMilkYield: 7.2,`n        lactationNumber: 3,`n        notes: "Ponni - Monitor",`n        lastUpdated: DateTime.now(),`n      ),`n      Cow(`n        id: "06666",`n        farmId: farmId,`n        rfid: "RFID_06666",`n        tagNumber: "06666",`n        dateOfBirth: DateTime.now().subtract(const Duration(days: 3 * 365)),`n        breed: "HF Cross",`n        currentRiskLevel: RiskLevel.low,`n        lastMilkYield: 9.1,`n        lactationNumber: 1,`n        notes: "Meena - Good",`n        lastUpdated: DateTime.now(),`n      ),`n    ];`n    notifyListeners();`n    return; // Bypass backend entirely for demo`n
    // _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cows = await _cowService.getCows(farmId);
    } catch (e) {
      _error = 'Failed to load herd';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addCowLocal(Cow cow) {
    _cows.insert(0, cow);
    notifyListeners();
  }

  void updateCowLocal(Cow updatedCow) {
    final index = _cows.indexWhere((c) => c.id == updatedCow.id);
    if (index != -1) {
      _cows[index] = updatedCow;
      notifyListeners();
    }
  }

  void setRiskFilter(RiskLevel? level) {
    _riskFilter = level;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // --- Milk History for Demo ---
  final Map<String, List<MilkReading>> _milkHistories = {};

  List<MilkReading> getMilkHistory(String cowId) => _milkHistories[cowId] ?? [];

  void addMilkReading(String cowId, MilkReading reading) {
    if (!_milkHistories.containsKey(cowId)) {
      _milkHistories[cowId] = [];
    }
    _milkHistories[cowId]!.add(reading);
    
    final cowIndex = _cows.indexWhere((c) => c.id == cowId);
    if (cowIndex != -1) {
      _cows[cowIndex] = _cows[cowIndex].copyWith(lastMilkYield: reading.yieldLiters);
    }
    notifyListeners();
  }
}
