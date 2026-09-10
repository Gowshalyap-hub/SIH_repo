import 'package:flutter/material.dart';
import '../../models/farm.dart';
import '../../services/api/api_farm_service.dart';

class FarmProvider extends ChangeNotifier {
  final ApiFarmService _farmService = ApiFarmService();
  
  Farm? _currentFarm;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = false;
  String? _error;

  Farm? get currentFarm => _currentFarm;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFarm(String ownerId) async {
    if (_currentFarm != null) return;
    
    _currentFarm = Farm(
      id: 'FARM001',
      name: 'MastiQ Dairy Farm',
      location: 'Tamil Nadu',
      ownerId: ownerId,
    );
    _dashboardData = {
      'totalCows': 3,
      'status': 'Active',
    };
    notifyListeners();
  }

  Future<void> updateFarm(Farm farm) async {
    _error = null;
    _currentFarm = farm;
    notifyListeners();
  }
}
