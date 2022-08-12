import 'package:surf_practice_chat_flutter/features/chat/exceptions/invalid_message_exception.dart';
import 'package:surf_practice_chat_flutter/features/chat/exceptions/user_not_found_exception.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_message_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_local_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/send_message_dto.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

/// Basic interface of chat features.
///
/// The only tool needed to implement the chat.
abstract class IChatRepository {
  /// Maximum length of one's message content,
  static const int maxMessageLength = 80;

  /// Returns messages [ChatMessageDto] from a source.
  ///
  /// Pay your attentions that there are two types of authors: [ChatUserDto]
  /// and [ChatUserLocalDto]. Second one representing message from user with
  /// the same name that you specified in [sendMessage].
  ///
  /// Throws an [Exception] when some error appears.
  Future<Iterable<ChatMessageDto>> getMessages(int chatId);

  /// Sends the message by with [message] content.
  ///
  /// Returns actual messages [ChatMessageDto] from a source (given your sent
  /// [message]).
  ///
  ///
  /// [message] mustn't be empty and longer than [maxMessageLength]. Throws an
  /// [InvalidMessageException].
  Future<Iterable<ChatMessageDto>> sendMessage(SendMessageDto message);

  /// Retrieves chat's user via his [userId].
  ///
  ///
  /// Throws an [UserNotFoundException] if user does not exist.
  ///
  /// Throws an [Exception] when some error appears.
  Future<ChatUserDto> getUser(int userId);
}

/// Simple implementation of [IChatRepository], using [StudyJamClient].
class ChatRepository implements IChatRepository {
  final StudyJamClient _studyJamClient;

  /// Constructor for [ChatRepository].
  ChatRepository(this._studyJamClient);

  @override
  Future<Iterable<ChatMessageDto>> getMessages(int chatId) async {
    final messages = await _fetchAllMessages(chatId);

    return messages;
  }

  @override
  Future<Iterable<ChatMessageDto>> sendMessage(SendMessageDto message) async {
    final messageText = message.text;

    if (messageText == null || messageText.isEmpty) {
      throw InvalidMessageException('Message "$message" is empty.');
    }

    if (messageText.length > IChatRepository.maxMessageLength) {
      throw InvalidMessageException('Message "$message" is too large.');
    }
    await _studyJamClient.sendMessage(SjMessageSendsDto(
      chatId: message.chatId,
      text: messageText,
      images: message.images?.toList(),
    ));

    final messages = await _fetchAllMessages(message.chatId);

    return messages;
  }

  @override
  Future<ChatUserDto> getUser(int userId) async {
    final user = await _studyJamClient.getUser(userId);
    if (user == null) {
      throw UserNotFoundException('User with id $userId had not been found.');
    }
    final localUser = await _studyJamClient.getUser();
    return localUser?.id == user.id ? ChatUserLocalDto.fromSJClient(user) : ChatUserDto.fromSJClient(user);
  }

  Future<Iterable<ChatMessageDto>> _fetchAllMessages(int chatId) async {
    final messages = <SjMessageDto>[];

    var isLimitBroken = false;
    var lastMessageId = 0;

    // Chat is loaded in a 10 000 messages batches. It takes several batches to
    // load chat completely, especially if there's a lot of messages. Due to
    // API-request limitations, we can't load everything at one request, so
    // we're doing it in cycle.
    while (!isLimitBroken) {
      final batch = await _studyJamClient.getMessages(chatId: chatId, lastMessageId: lastMessageId, limit: 10000);
      messages.addAll(batch);

      if (batch.isEmpty) return [];

      lastMessageId = batch.last.chatId;
      if (batch.length < 10000) {
        isLimitBroken = true;
      }
    }

    // Message ID : User ID
    final messagesWithUsers = <int, int>{};
    for (final message in messages) {
      messagesWithUsers[message.id] = message.userId;
    }
    final users = await _studyJamClient.getUsers(messagesWithUsers.values.toSet().toList());
    final localUser = await _studyJamClient.getUser();

    return messages
        .map(
          (sjMessageDto) {
            return ChatMessageDto.fromSJClient(
              sjMessageDto: sjMessageDto,
              sjUserDto: users.firstWhere((userDto) => userDto.id == sjMessageDto.userId),
              isUserLocal: users.firstWhere((userDto) => userDto.id == sjMessageDto.userId).id == localUser?.id,
            );
          },
        )
        .toList();
  }
}
