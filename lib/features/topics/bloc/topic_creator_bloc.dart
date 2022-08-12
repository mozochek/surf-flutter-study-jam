import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:surf_practice_chat_flutter/features/topics/models/chat_topic_dto.dart';
import 'package:surf_practice_chat_flutter/features/topics/models/chat_topic_send_dto.dart';
import 'package:surf_practice_chat_flutter/features/topics/repository/chat_topics_repository.dart';

part 'topic_creator_bloc.freezed.dart';

class TopicCreatorBloc extends Bloc<TopicCreatorEvent, TopicCreatorState> {
  final IChatTopicsRepository _chatTopicsRepository;

  TopicCreatorBloc({
    required IChatTopicsRepository chatTopicsRepository,
  })  : _chatTopicsRepository = chatTopicsRepository,
        super(const TopicCreatorState.notInitialized()) {
    on<TopicCreatorEvent>(
      (event, emit) async => event.map(
        create: (event) => _onCreate(event, emit),
      ),
      transformer: bloc_concurrency.droppable(),
    );
  }

  Future<void> _onCreate(_TopicCreatorEventCreate event, Emitter<TopicCreatorState> emit) async {
    try {
      emit(const TopicCreatorState.inProgress());
      final createdTopic = await _chatTopicsRepository.createTopic(event.chatTopicSendDto);
      emit(TopicCreatorState.completed(createdTopic));
    } on Object {
      emit(const TopicCreatorState.failed());
      rethrow;
    }
  }
}

@freezed
class TopicCreatorEvent with _$TopicCreatorEvent {
  const TopicCreatorEvent._();

  const factory TopicCreatorEvent.create(
    ChatTopicSendDto chatTopicSendDto,
  ) = _TopicCreatorEventCreate;
}

@freezed
class TopicCreatorState with _$TopicCreatorState {
  const TopicCreatorState._();

  const factory TopicCreatorState.notInitialized() = _TopicCreatorStateNotInitialized;

  const factory TopicCreatorState.inProgress() = _TopicCreatorStateInProgress;

  const factory TopicCreatorState.completed(
    ChatTopicDto chatTopicDto,
  ) = _TopicCreatorStateCompleted;

  const factory TopicCreatorState.failed() = _TopicCreatorStateFailed;
}
