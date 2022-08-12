import 'package:surf_practice_chat_flutter/features/auth/domain/models/user_with_token_dto.dart';

/// Basic interface of authorization logic.
///
/// Has 2 methods: [signIn] & [signOut].
abstract class IAuthRepository {
  /// Signs the user in via [login] & [password].
  ///
  /// [login] is a `String` representation of login,
  /// that was used in registration.
  ///
  /// [password] is a `String` representation of a password,
  /// that was used in registration.
  ///
  /// [TokenDto] is a model, containing its' value, that should be
  /// retrieved in the end of authorization process.
  ///
  /// May throw an [AuthException].
  Future<UserWithTokenDto> signIn({
    required String login,
    required String password,
  });

  /// Signs the user out, clearing all unneeded credentials.
  Future<void> signOut();
}
