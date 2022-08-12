import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:surf_practice_chat_flutter/features/chat/domain/models/send_message_dto.dart';

part 'current_message_bloc.freezed.dart';

class CurrentMessageBloc extends Bloc<CurrentMessageEvent, CurrentMessageState> {
  CurrentMessageBloc() : super(const CurrentMessageState()) {
    on<CurrentMessageEvent>(
      (event, emit) => event.map(
        setText: (event) => _onSetText(event, emit),
        addCoordinates: (event) => _onAddCoordinates(event, emit),
        addImages: (event) => _onAddImages(event, emit),
        reset: (_) => _onReset(_, emit),
      ),
    );
  }

  void _onSetText(_CurrentMessageEventSetText event, Emitter<CurrentMessageState> emit) {
    emit(state.copyWith(text: event.text.trim()));
  }

  void _onAddCoordinates(_CurrentMessageEventAddCoordinates event, Emitter<CurrentMessageState> emit) {
    emit(state.copyWith(coordinates: event.coordinates));
  }

  void _onAddImages(_CurrentMessageEventAddImages event, Emitter<CurrentMessageState> emit) {
    emit(state.copyWith(images: event.imagesPaths));
  }

  void _onReset(_CurrentMessageEventReset event, Emitter<CurrentMessageState> emit) {
    emit(const CurrentMessageState());
  }
}

@freezed
class CurrentMessageEvent with _$CurrentMessageEvent {
  const CurrentMessageEvent._();

  const factory CurrentMessageEvent.setText(String text) = _CurrentMessageEventSetText;

  const factory CurrentMessageEvent.addCoordinates(LatLng coordinates) = _CurrentMessageEventAddCoordinates;

  const factory CurrentMessageEvent.addImages(Iterable<String> imagesPaths) = _CurrentMessageEventAddImages;

  const factory CurrentMessageEvent.reset() = _CurrentMessageEventReset;
}

@freezed
class CurrentMessageState with _$CurrentMessageState {
  const CurrentMessageState._();

  const factory CurrentMessageState({
    String? text,
    LatLng? coordinates,
    Iterable<String>? images,
  }) = _CurrentMessageState;

  bool get isMessageValid => text != null && text!.isNotEmpty;
}
