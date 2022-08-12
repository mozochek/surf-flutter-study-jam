import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surf_practice_chat_flutter/features/auth/models/token_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/bloc/current_message_bloc.dart';
import 'package:surf_practice_chat_flutter/features/chat/bloc/message_sender_bloc.dart';
import 'package:surf_practice_chat_flutter/features/chat/bloc/messages_loading_bloc.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/send_message_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

class ChatScreenScope extends StatefulWidget {
  final TokenDto tokenDto;
  final Widget child;

  const ChatScreenScope({
    required this.tokenDto,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatScreenScope> createState() => _ChatScreenScopeState();

  static MessagesLoadingBloc messagesLoadingBloc(BuildContext context) => context.read<MessagesLoadingBloc>();

  static CurrentMessageBloc currentMessageBloc(BuildContext context) => context.read<CurrentMessageBloc>();

  static MessageSenderBloc messageSenderBloc(BuildContext context) => context.read<MessageSenderBloc>();

  static void loadMessages(BuildContext context) => messagesLoadingBloc(context).add(const MessagesLoadingEvent.load());

  static void setMessageText(BuildContext context, String text) =>
      currentMessageBloc(context).add(CurrentMessageEvent.setText(text));

  static void addImages(BuildContext context, Iterable<String> imagesPaths) =>
      currentMessageBloc(context).add(CurrentMessageEvent.addImages(imagesPaths));

  static void resetCurrentMessage(BuildContext context) =>
      currentMessageBloc(context).add(const CurrentMessageEvent.reset());

  static void tryToSendCurrentMessage(BuildContext context) {
    final messageState = currentMessageBloc(context).state;

    final sendMessageDto = SendMessageDto(
      text: messageState.text,
      images: messageState.images,
    );

    messageSenderBloc(context).add(MessageSenderEvent.send(sendMessageDto));
  }
}

class _ChatScreenScopeState extends State<ChatScreenScope> {
  late final IChatRepository _chatRepository;

  @override
  void initState() {
    super.initState();

    _chatRepository = ChatRepository(
      StudyJamClient().getAuthorizedClient(widget.tokenDto.token),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MessagesLoadingBloc(
            chatRepository: _chatRepository,
          )..add(const MessagesLoadingEvent.load()),
        ),
        BlocProvider(create: (_) => MessageSenderBloc(chatRepository: _chatRepository)),
        BlocProvider(create: (_) => CurrentMessageBloc()),
      ],
      child: BlocListener<MessageSenderBloc, MessageSenderState>(
        listener: (context, state) => state.mapOrNull(
          inProgress: (_) => ChatScreenScope.resetCurrentMessage(context),
        ),
        child: widget.child,
      ),
    );
  }
}
