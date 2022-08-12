import 'package:surf_practice_chat_flutter/features/topics/domain/models/chat_topic_dto.dart';
import 'package:surf_practice_chat_flutter/features/topics/domain/models/chat_topic_send_dto.dart';
import 'package:surf_practice_chat_flutter/features/topics/domain/repository/i_chat_topics_repository.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

/// Simple implementation of [IChatTopicsRepository], using [StudyJamClient].
class ChatTopicsRepository implements IChatTopicsRepository {
  final StudyJamClient _studyJamClient;

  /// Constructor for [ChatTopicsRepository].
  ChatTopicsRepository(this._studyJamClient);

  @override
  Future<Iterable<ChatTopicDto>> getTopics({
    required DateTime topicsStartDate,
  }) async {
    final updates = await _studyJamClient.getUpdates(chats: topicsStartDate);
    final topicsIds = updates.chats;
    if (topicsIds == null) {
      return [];
    }
    final topics = await _studyJamClient.getChatsByIds(topicsIds);

    return topics.map((sjChatDto) => ChatTopicDto.fromSJClient(sjChatDto: sjChatDto));
  }

  @override
  Future<ChatTopicDto> createTopic(ChatTopicSendDto chatTopicSendDto) async {
    final sjChatDto = await _studyJamClient.createChat(chatTopicSendDto.toSjChatSendsDto());

    return ChatTopicDto.fromSJClient(sjChatDto: sjChatDto);
  }
}
