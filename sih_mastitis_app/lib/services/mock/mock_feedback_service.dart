import '../../models/feedback.dart';

class MockFeedbackService {
  Future<void> submitFeedback(Feedback feedback) async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulate successful submission
    return;
  }
}
