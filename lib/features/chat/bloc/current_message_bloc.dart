import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/send_message_dto.dart';

part 'current_message_bloc.freezed.dart';

class CurrentMessageBloc extends Bloc<CurrentMessageEvent, CurrentMessageState> {
  CurrentMessageBloc() : super(const CurrentMessageState()) {
    on<CurrentMessageEvent>((event, emit) {
      event.map(
        setText: (event) {
          emit(state.copyWith(text: event.text));
        },
        addCoordinates: (event) {
          emit(state.copyWith(coordinates: event.coordinates));
        },
        addImages: (event) {
          emit(state.copyWith(images: event.imagesPaths));
        },
        reset: (_) {
          emit(const CurrentMessageState());
        }
      );
    });
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

    /// Images paths in file system
    Iterable<String>? images,
  }) = _CurrentMessageState;
}
