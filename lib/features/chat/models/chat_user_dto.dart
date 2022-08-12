import 'package:surf_practice_chat_flutter/features/core/models/user_dto.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

/// Model, representing chat user.
class ChatUserDto extends UserDto {
  /// Constructor for [ChatUserDto].
  const ChatUserDto({
    required int id,
    required String? name,
    required String login,
  }) : super(id: id, name: name, login: login);

  /// Factory constructor for converting DTO from [StudyJamClient].
  factory ChatUserDto.fromSJClient(SjUserDto sjUserDto) => ChatUserDto(
        id: sjUserDto.id,
        name: sjUserDto.username?.trim(),
        login: sjUserDto.login.trim(),
      );
}
