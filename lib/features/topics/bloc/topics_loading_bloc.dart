import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:surf_practice_chat_flutter/features/topics/models/chat_topic_dto.dart';
import 'package:surf_practice_chat_flutter/features/topics/repository/chat_topics_repository.dart';

part 'topics_loading_bloc.freezed.dart';

class TopicsLoadingBloc extends Bloc<TopicsLoadingEvent, TopicsLoadingState> {
  final IChatTopicsRepository _chatTopicsRepository;

  TopicsLoadingBloc({
    required IChatTopicsRepository chatTopicsRepository,
  })  : _chatTopicsRepository = chatTopicsRepository,
        super(const TopicsLoadingState.notInitialized()) {
    on<TopicsLoadingEvent>(
      (event, emit) async {
        await event.map(
          load: (event) async {
            try {
              emit(const TopicsLoadingState.inProgress());
              final chats = await _chatTopicsRepository.getTopics(
                topicsStartDate: DateTime(2022, 8, 10),
              );
              emit(TopicsLoadingState.completed(chats));
            } on Object {
              emit(const TopicsLoadingState.failed());
              rethrow;
            }
          },
        );
      },
      transformer: bloc_concurrency.droppable(),
    );
  }
}

@freezed
class TopicsLoadingEvent with _$TopicsLoadingEvent {
  const TopicsLoadingEvent._();

  const factory TopicsLoadingEvent.load() = _TopicsLoadingEventLoad;
}

@freezed
class TopicsLoadingState with _$TopicsLoadingState {
  const TopicsLoadingState._();

  const factory TopicsLoadingState.notInitialized() = _TopicsLoadingStateNotInitialized;

  const factory TopicsLoadingState.inProgress() = _TopicsLoadingStateInProgress;

  const factory TopicsLoadingState.completed(
    Iterable<ChatTopicDto> chats,
  ) = _TopicsLoadingStateCompleted;

  const factory TopicsLoadingState.failed() = _TopicsLoadingStateFailed;
}
