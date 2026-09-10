import '../../models/user.dart';

class MockAuthService {
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return User(
      id: 'usr_001',
      name: 'John Doe',
      email: email,
      phone: '+1234567890',
      role: 'Farmer',
      farmId: 'FARM001',
    );
  }
}
