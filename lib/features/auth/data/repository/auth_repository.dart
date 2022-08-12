import 'package:surf_practice_chat_flutter/features/auth/data/exceptions/auth_exception.dart';
import 'package:surf_practice_chat_flutter/features/auth/domain/models/token_dto.dart';
import 'package:surf_practice_chat_flutter/features/auth/domain/models/user_with_token_dto.dart';
import 'package:surf_practice_chat_flutter/features/auth/domain/repository/i_auth_repository.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

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
