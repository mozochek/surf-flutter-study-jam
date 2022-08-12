import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surf_practice_chat_flutter/features/core/presentation/scope/authorized_scope.dart';
import 'package:surf_practice_chat_flutter/features/topics/features/all_topics/presentation/bloc/topics_loading_bloc.dart';
import 'package:surf_practice_chat_flutter/features/topics/data/repository/chat_topics_repository.dart';

class TopicsScreenScope extends StatelessWidget {
  final Widget child;

  const TopicsScreenScope({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => TopicsLoadingBloc(
            chatTopicsRepository: ChatTopicsRepository(
              AuthorizedScope.authorizedClient(context),
            ),
          )..add(const TopicsLoadingEvent.load()),
        ),
      ],
      child: child,
    );
  }

  static TopicsLoadingBloc topicsLoadingBloc(BuildContext context) => context.read<TopicsLoadingBloc>();

  static void loadTopics(BuildContext context) => topicsLoadingBloc(context).add(const TopicsLoadingEvent.load());
}
