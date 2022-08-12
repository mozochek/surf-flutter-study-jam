import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'topic_creation_form_bloc.freezed.dart';

class TopicCreationFormBloc extends Bloc<TopicCreationFormEvent, TopicCreationFormState> {
  TopicCreationFormBloc() : super(const TopicCreationFormState()) {
    on<TopicCreationFormEvent>(
      (event, emit) => event.map(
        setTitle: (event) => _onSetTitle(event, emit),
        setDescription: (event) => _onSetDescription(event, emit),
      ),
    );
  }

  void _onSetTitle(_TopicCreationFormEventSetTitle event, Emitter<TopicCreationFormState> emit) {
    emit(state.copyWith(title: event.title.trim()));
  }

  void _onSetDescription(_TopicCreationFormEventSetDescription event, Emitter<TopicCreationFormState> emit) {
    emit(state.copyWith(description: event.description.trim()));
  }
}

@freezed
class TopicCreationFormEvent with _$TopicCreationFormEvent {
  const TopicCreationFormEvent._();

  const factory TopicCreationFormEvent.setTitle(String title) = _TopicCreationFormEventSetTitle;

  const factory TopicCreationFormEvent.setDescription(String description) = _TopicCreationFormEventSetDescription;
}

@freezed
class TopicCreationFormState with _$TopicCreationFormState {
  const TopicCreationFormState._();

  const factory TopicCreationFormState({
    String? title,
    String? description,
  }) = _TopicCreationFormState;

  bool get isRequiredFieldsFilled => title != null && title!.isNotEmpty;
}
