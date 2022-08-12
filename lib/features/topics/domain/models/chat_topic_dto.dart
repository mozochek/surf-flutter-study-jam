import 'package:surf_study_jam/surf_study_jam.dart';

/// Data transfer object representing simple chat topic.
///
/// Is different from [ChatTopicSendDto], because it does contain id.
/// This topic has already been created in API.
class ChatTopicDto {
  /// Topic's unique id.
  final int id;

  /// Topic's name.
  ///
  /// Should be less than 128 characters long.
  final String name;

  /// Topic's description.
  ///
  /// Should be less than 1024 characters long.
  final String? description;

  final String? avatar;

  /// Constructor for [ChatTopicDto].
  const ChatTopicDto({
    required this.id,
    required this.name,
    this.description,
    this.avatar,
  });

  /// Named constructor for converting DTO from [StudyJamClient].
  factory ChatTopicDto.fromSJClient({
    required SjChatDto sjChatDto,
  }) {
    final name = sjChatDto.name?.trim() ?? '';

    return ChatTopicDto(
      id: sjChatDto.id,
      description: sjChatDto.description,
      name: name.isEmpty ? '<no-name>' : name,
      avatar: Uri.tryParse(sjChatDto.avatar ?? '')?.isAbsolute ?? false ? sjChatDto.avatar : null,
    );
  }

  @override
  String toString() => 'ChatTopicDto(id: $id, name: $name, description: $description)';
}
