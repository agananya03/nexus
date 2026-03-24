import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../../../core/api_service.dart';

class AuthNotifier extends AsyncNotifier<UserModel?> {
  final _storage = const FlutterSecureStorage();

  @override
  Future<UserModel?> build() async {
    return tryAutoLogin();
  }

  Future<UserModel?> tryAutoLogin() async {
    final token = await _storage.read(key: 'jwt');
    if (token == null) return null;

    try {
      final response = await apiService.get('/auth/me');
      return UserModel.fromJson(response);
    } catch (e) {
      await _storage.delete(key: 'jwt');
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });
      await _storage.write(key: 'jwt', value: response['access_token']);
      final userResp = await apiService.get('/auth/me');
      return UserModel.fromJson(userResp);
    });
  }

  Future<void> register(String name, String email, String password, String? college, String? branch, int? year, int? semester) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await apiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'college': college,
        'branch': branch,
        'year': year,
        'semester': semester,
      });
      await _storage.write(key: 'jwt', value: response['access_token']);
      final userResp = await apiService.get('/auth/me');
      return UserModel.fromJson(userResp);
    });
  }

  Future<void> loginWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) throw Exception('Google Sign In cancelled');
      
      final GoogleSignInAuthentication auth = await account.authentication;
      final response = await apiService.post('/auth/google', {
        'id_token': auth.idToken,
      });
      await _storage.write(key: 'jwt', value: response['access_token']);
      final userResp = await apiService.get('/auth/me');
      return UserModel.fromJson(userResp);
    });
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
    await GoogleSignIn().signOut();
    state = const AsyncValue.data(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(() {
  return AuthNotifier();
});
