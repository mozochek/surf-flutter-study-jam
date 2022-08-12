import 'package:surf_practice_chat_flutter/features/topics/domain/models/chat_topic_dto.dart';
import 'package:surf_practice_chat_flutter/features/topics/domain/models/chat_topic_send_dto.dart';

/// Basic interface for chat topics features.
///
/// The only tool needed to implement the chat topics.
abstract class IChatTopicsRepository {
  /// Gets all chat topics.
  ///
  /// Use [topicsStartDate] to specify from which moment, you
  /// would like to get topics. For example, if topic was made
  /// yesterday & you want to retrieve it, you should pass
  /// [DateTime.now].subtract(Duration(days:1))
  Future<Iterable<ChatTopicDto>> getTopics({
    required DateTime topicsStartDate,
  });

  /// Creates new chat topic.
  ///
  /// Retrieves [ChatTopicDto] with its unique id, once its
  /// created.
  Future<ChatTopicDto> createTopic(ChatTopicSendDto chatTopicSendDto);
}
