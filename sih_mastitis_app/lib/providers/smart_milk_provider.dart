import 'package:flutter/material.dart';
import '../../models/cow.dart';
import '../../models/smart_cup.dart';
import '../../models/milking_session.dart';
import '../../models/milk_reading.dart';
import '../../services/api/api_smart_cup_service.dart';

enum SmartMilkStep { initial, scanningRFID, connectCup, liveData, reviewAndSave, completed }

class SmartMilkProvider extends ChangeNotifier {
  final ApiSmartCupService _cupService = ApiSmartCupService();

  SmartMilkStep _currentStep = SmartMilkStep.initial;
  Cow? _selectedCow;
  SmartCup? _connectedCup;
  MilkingSession? _currentSession;
  MilkReading? _liveReading;

  bool _isLoading = false;
  String? _error;

  SmartMilkStep get currentStep => _currentStep;
  Cow? get selectedCow => _selectedCow;
  SmartCup? get connectedCup => _connectedCup;
  MilkingSession? get currentSession => _currentSession;
  MilkReading? get liveReading => _liveReading;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void reset() {
    _currentStep = SmartMilkStep.initial;
    _selectedCow = null;
    _connectedCup = null;
    _currentSession = null;
    _liveReading = null;
    _error = null;
    notifyListeners();
  }

  Future<void> step1ScanRFID(Cow cow) async {
    _selectedCow = cow;
    _currentStep = SmartMilkStep.connectCup;
    notifyListeners();
  }

  Future<void> step2ConnectCup(String cupId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _connectedCup = await _cupService.getSmartCupStatus(cupId);
      if (_selectedCow != null && _connectedCup != null) {
        _currentSession = await _cupService.startMilkingSession(_selectedCow!.id, _connectedCup!.id);
        _currentStep = SmartMilkStep.liveData;
      }
    } catch (e) {
      _error = 'Failed to connect Smart Cup';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> step3StopLiveData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_currentSession != null) {
        _liveReading = await _cupService.endMilkingSession(_currentSession!.id);
        _currentStep = SmartMilkStep.reviewAndSave;
      }
    } catch (e) {
      _error = 'Failed to stop live data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> step4SaveSession() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1)); // Mock upload
      _currentStep = SmartMilkStep.completed;
    } catch (e) {
      _error = 'Failed to save session';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
