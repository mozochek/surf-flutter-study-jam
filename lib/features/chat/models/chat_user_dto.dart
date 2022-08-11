import 'package:surf_study_jam/surf_study_jam.dart';

/// Basic model, representing chat user.
class ChatUserDto {
  final int id;

  /// User's name.
  ///
  /// May be `null`.
  final String? name;

  /// Constructor for [ChatUserDto].
  const ChatUserDto({
    required this.id,
    required this.name,
  });

  /// Factory-like constructor for converting DTO from [StudyJamClient].
  ChatUserDto.fromSJClient(SjUserDto sjUserDto)
      : id = sjUserDto.id,
        name = sjUserDto.username;

  bool get haveName => name != null;

  String get initials {
    if (haveName == false) return '??';

    final firstAndLastNames = name!.split(' ');

    return '${firstAndLastNames.first[0]}${firstAndLastNames.last[0]}';
  }

  @override
  String toString() => 'ChatUserDto(id: $id, name: $name)';
}
