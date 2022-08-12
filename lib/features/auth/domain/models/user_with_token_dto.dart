import 'package:surf_practice_chat_flutter/features/auth/domain/models/token_dto.dart';
import 'package:surf_practice_chat_flutter/features/core/domain/models/user_dto.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

class UserWithTokenDto extends UserDto {
  final TokenDto tokenDto;

  const UserWithTokenDto({
    required this.tokenDto,
    required int id,
    required String? name,
    required String login,
  }) : super(id: id, name: name, login: login);

  factory UserWithTokenDto.fromSJClient({
    required TokenDto tokenDto,
    required SjUserDto sjUserDto,
  }) =>
      UserWithTokenDto(
        tokenDto: tokenDto,
        id: sjUserDto.id,
        name: sjUserDto.username,
        login: sjUserDto.login,
      );
}
