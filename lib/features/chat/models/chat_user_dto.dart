import 'package:surf_study_jam/surf_study_jam.dart';

/// Basic model, representing chat user.
class ChatUserDto {
  final int id;

  /// User's name.
  ///
  /// May be `null`.
  final String? name;

  final String login;

  /// Constructor for [ChatUserDto].
  const ChatUserDto({
    required this.id,
    required this.name,
    required this.login,
  });

  /// Factory-like constructor for converting DTO from [StudyJamClient].
  ChatUserDto.fromSJClient(SjUserDto sjUserDto)
      : id = sjUserDto.id,
        name = sjUserDto.username?.trim(),
        login = sjUserDto.login.trim();

  bool get haveName => name != null;

  String get displayName => name ?? (login.isNotEmpty ? login : '<name>');

  String get initials {
    if (haveName == false || name == null || name?.isEmpty == true) {
      return login[0];
    }

    final firstAndLastNames = name!.split(' ');

    if (firstAndLastNames.length < 2) {
      return firstAndLastNames.first[0];
    }

    return '${firstAndLastNames.first[0]}${firstAndLastNames.last[0]}';
  }

  @override
  String toString() => 'ChatUserDto(id: $id, name: $name, login: $login)';
}
