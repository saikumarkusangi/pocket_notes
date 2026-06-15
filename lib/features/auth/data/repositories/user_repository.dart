import 'package:dio/dio.dart';
import 'package:pocket_notes/core/constants/api_endpoints.dart';
import 'package:pocket_notes/features/auth/data/models/google_auth_result.dart';
import 'package:pocket_notes/features/auth/data/models/user_model.dart';

class UserRepository {
  UserRepository(this._dio);

  final Dio _dio;

  Future<UserModel?> findUserByEmail(String email) async {
    final response = await _dio.get<List<dynamic>>(
      ApiEndpoints.users,
      queryParameters: {'email': email},
    );

    final users = _parseUsers(response.data);
    final match = users.where((user) => user.email == email);
    return match.isEmpty ? null : match.first;
  }

  Future<UserModel> createUser({
    required String email,
    String? name,
    String? photoUrl,
    String? googleId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.users,
      data: {
        'email': email,
        if (name != null) 'name': name,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (googleId != null) 'googleId': googleId,
      },
    );

    return UserModel.fromJson(response.data ?? {});
  }

  Future<UserModel> syncUserAfterLogin(GoogleAuthUser googleUser) async {
    final existingUser = await findUserByEmail(googleUser.email);
    if (existingUser != null) {
      return existingUser;
    }

    return createUser(
      email: googleUser.email,
      name: googleUser.displayName,
      photoUrl: googleUser.photoUrl,
      googleId: googleUser.id,
    );
  }

  List<UserModel> _parseUsers(List<dynamic>? data) {
    if (data == null) return [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(UserModel.fromJson)
        .toList();
  }
}
