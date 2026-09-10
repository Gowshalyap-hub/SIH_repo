import 'package:flutter/material.dart';
import '../../models/feedback.dart' as app_feedback;
import '../../services/api/api_feedback_service.dart';

class FeedbackProvider extends ChangeNotifier {
  final ApiFeedbackService _service = ApiFeedbackService();

  bool _isSubmitting = false;
  String? _error;
  bool _isSuccess = false;

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  bool get isSuccess => _isSuccess;

  Future<void> submitFeedback(app_feedback.Feedback feedbackData) async {
    _isSubmitting = true;
    _error = null;
    _isSuccess = false;
    notifyListeners();

    try {
      await _service.submitFeedback(feedbackData);
      _isSuccess = true;
    } catch (e) {
      _error = 'Failed to submit feedback';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
