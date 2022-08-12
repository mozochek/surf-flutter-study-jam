import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:surf_practice_chat_flutter/features/chat/domain/models/send_message_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/domain/repository/i_chat_repository.dart';

part 'message_sender_bloc.freezed.dart';

class MessageSenderBloc extends Bloc<MessageSenderEvent, MessageSenderState> {
  final IChatRepository _chatRepository;

  MessageSenderBloc({
    required IChatRepository chatRepository,
  })  : _chatRepository = chatRepository,
        super(const MessageSenderState.notInitialized()) {
    on<MessageSenderEvent>(
      (event, emit) => event.map(
        send: (event) => _onSend(event, emit),
      ),
      transformer: bloc_concurrency.concurrent(),
    );
  }

  Future<void> _onSend(_MessageSenderEventSend event, Emitter<MessageSenderState> emit) async {
    try {
      emit(const MessageSenderState.inProgress());
      await _chatRepository.sendMessage(event.sendMessageDto);
      emit(const MessageSenderState.completed());
    } on Object {
      emit(const MessageSenderState.failed());
      rethrow;
    }
  }
}

@freezed
class MessageSenderEvent with _$MessageSenderEvent {
  const MessageSenderEvent._();

  const factory MessageSenderEvent.send(SendMessageDto sendMessageDto) = _MessageSenderEventSend;
}

@freezed
class MessageSenderState with _$MessageSenderState {
  const MessageSenderState._();

  const factory MessageSenderState.notInitialized() = _MessageSenderStateNotInitialized;

  const factory MessageSenderState.inProgress() = _MessageSenderStateInProgress;

  const factory MessageSenderState.completed() = _MessageSenderStateCompleted;

  const factory MessageSenderState.failed() = _MessageSenderStateFailed;
}
