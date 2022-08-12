import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surf_practice_chat_flutter/features/core/scope/authorized_scope.dart';
import 'package:surf_practice_chat_flutter/features/topics/bloc/topic_creation_form_bloc.dart';
import 'package:surf_practice_chat_flutter/features/topics/bloc/topic_creator_bloc.dart';
import 'package:surf_practice_chat_flutter/features/topics/models/chat_topic_send_dto.dart';
import 'package:surf_practice_chat_flutter/features/topics/repository/chat_topics_repository.dart';

class CreateTopicScreenScope extends StatelessWidget {
  final Widget child;

  const CreateTopicScreenScope({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TopicCreationFormBloc()),
        BlocProvider(
          create: (context) => TopicCreatorBloc(
            chatTopicsRepository: ChatTopicsRepository(
              AuthorizedScope.authorizedClient(context),
            ),
          ),
        ),
      ],
      child: BlocListener<TopicCreatorBloc, TopicCreatorState>(
        listener: (context, state) => state.mapOrNull(
          completed: (_) => Navigator.maybePop(context),
        ),
        child: child,
      ),
    );
  }

  static TopicCreationFormBloc topicCreationFormBloc(BuildContext context) => context.read<TopicCreationFormBloc>();

  static TopicCreatorBloc topicCreatorBloc(BuildContext context) => context.read<TopicCreatorBloc>();

  static void setTopicTitle(BuildContext context, String title) =>
      topicCreationFormBloc(context).add(TopicCreationFormEvent.setTitle(title));

  static void setTopicDescription(BuildContext context, String description) =>
      topicCreationFormBloc(context).add(TopicCreationFormEvent.setDescription(description));

  static void tryToCreateTopic(BuildContext context) {
    final topicForm = topicCreationFormBloc(context).state;

    if (topicForm.isRequiredFieldsFilled) {
      topicCreatorBloc(context).add(
        TopicCreatorEvent.create(
          ChatTopicSendDto(name: topicForm.title, description: topicForm.description),
        ),
      );
    }
  }
}
