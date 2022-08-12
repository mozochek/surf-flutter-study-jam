import 'package:surf_practice_chat_flutter/features/auth/exceptions/auth_exception.dart';
import 'package:surf_practice_chat_flutter/features/auth/models/token_dto.dart';
import 'package:surf_practice_chat_flutter/features/auth/models/user_with_token_dto.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

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

/// Simple implementation of [IAuthRepository], using [StudyJamClient].
class AuthRepository implements IAuthRepository {
  final StudyJamClient _studyJamClient;

  /// Constructor for [AuthRepository].
  AuthRepository(this._studyJamClient);

  @override
  Future<UserWithTokenDto> signIn({
    required String login,
    required String password,
  }) async {
    try {
      final token = await _studyJamClient.signin(login, password);
      final authorizedClient = _studyJamClient.getAuthorizedClient(token);
      final sjUserDto = await authorizedClient.getUser();

      if (sjUserDto == null) {
        throw const AuthException('User not found');
      }

      return UserWithTokenDto.fromSJClient(
        tokenDto: TokenDto(token: token),
        sjUserDto: sjUserDto,
      );
    } on Object catch (e, s) {
      Error.throwWithStackTrace(AuthException(e.toString()), s);
    }
  }

  @override
  Future<void> signOut() {
    return _studyJamClient.logout();
  }
}
