import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:surf_practice_chat_flutter/features/chat/domain/models/chat_message_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/domain/repository/i_chat_repository.dart';

part 'messages_loading_bloc.freezed.dart';

class MessagesLoadingBloc extends Bloc<MessagesLoadingEvent, MessagesLoadingState> {
  final IChatRepository _chatRepository;

  MessagesLoadingBloc({
    required IChatRepository chatRepository,
  })  : _chatRepository = chatRepository,
        super(const MessagesLoadingState.notInitialized()) {
    on<MessagesLoadingEvent>(
      (event, emit) async => event.map(
        load: (event) => _onLoad(event, emit),
      ),
      transformer: bloc_concurrency.droppable(),
    );
  }

  Future<void> _onLoad(_MessagesLoadingEventLoad event, Emitter<MessagesLoadingState> emit) async {
    try {
      emit(const MessagesLoadingState.inProgress());
      final messages = await _chatRepository.getMessages(event.chatId);
      emit(MessagesLoadingState.completed(messages));
    } on Object {
      emit(const MessagesLoadingState.failed());
      rethrow;
    }
  }
}

@freezed
class MessagesLoadingEvent with _$MessagesLoadingEvent {
  const MessagesLoadingEvent._();

  const factory MessagesLoadingEvent.load(int chatId) = _MessagesLoadingEventLoad;
}

@freezed
class MessagesLoadingState with _$MessagesLoadingState {
  const MessagesLoadingState._();

  const factory MessagesLoadingState.notInitialized() = _MessagesLoadingStateNotInitialized;

  const factory MessagesLoadingState.inProgress() = _MessagesLoadingStateInProgress;

  const factory MessagesLoadingState.completed(
    Iterable<ChatMessageDto> messages,
  ) = _MessagesLoadingStateCompleted;

  const factory MessagesLoadingState.failed() = _MessagesLoadingStateFailed;
}
