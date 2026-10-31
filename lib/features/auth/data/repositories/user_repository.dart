import 'package:pocket_notes/core/network/github_database.dart';
import 'package:pocket_notes/features/auth/data/models/google_auth_result.dart';
import 'package:pocket_notes/features/auth/data/models/user_model.dart';

class UserRepository {
  UserRepository(this._database);

  final GithubDatabase _database;
  static final String _usersPath = githubDatabasePath('users.json');

  Future<UserModel?> findUserByEmail(String email) {
    return _database.run((session) async {
      final users = await session.readJsonList(_usersPath);
      for (final user in users) {
        if (user['email'] == email) return UserModel.fromJson(user);
      }
      return null;
    });
  }

  Future<UserModel> createUser({
    required String email,
    String? name,
    String? photoUrl,
    String? googleId,
  }) {
    return _database.run((session) async {
      final users = await session.readJsonList(_usersPath);
      final record = <String, dynamic>{
        'id': nextRecordId(users),
        'email': email,
        'name': name,
        'photoUrl': photoUrl,
        'googleId': googleId,
        'createdAt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };
      users.add(record);
      await session.writeJsonList(
        path: _usersPath,
        records: users,
        message: 'Add user ${record['id']}',
      );
      return UserModel.fromJson(record);
    });
  }

  Future<UserModel> syncUserAfterLogin(GoogleAuthUser googleUser) async {
    final existingUser = await findUserByEmail(googleUser.email);
    if (existingUser != null) return existingUser;
    return createUser(
      email: googleUser.email,
      name: googleUser.displayName,
      photoUrl: googleUser.photoUrl,
      googleId: googleUser.id,
    );
  }
}
