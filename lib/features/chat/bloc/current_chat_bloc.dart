import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'current_chat_bloc.freezed.dart';

class CurrentChatBloc extends Bloc<CurrentChatEvent, CurrentChatState> {
  CurrentChatBloc({
    required int chatId,
  }) : super(CurrentChatState(chatId: chatId)) {
    on<CurrentChatEvent>((event, emit) {
      event.map(setChatId: (event) {
        emit(state.copyWith(chatId: event.chatId));
      });
    });
  }
}

@freezed
class CurrentChatEvent with _$CurrentChatEvent {
  const CurrentChatEvent._();

  const factory CurrentChatEvent.setChatId(int chatId) = _CurrentChatEventSetChatId;
}

@freezed
class CurrentChatState with _$CurrentChatState {
  const CurrentChatState._();

  const factory CurrentChatState({
    required int chatId,
  }) = _CurrentChatState;
}
