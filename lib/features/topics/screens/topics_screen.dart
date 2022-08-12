import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:surf_practice_chat_flutter/features/auth/models/user_with_token_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/screens/chat_screen.dart';
import 'package:surf_practice_chat_flutter/features/core/l10n/app_localizations.dart';
import 'package:surf_practice_chat_flutter/features/core/scope/authorized_scope.dart';
import 'package:surf_practice_chat_flutter/features/core/widgets/app_icon_button.dart';
import 'package:surf_practice_chat_flutter/features/core/widgets/overscroll_glow_disabler.dart';
import 'package:surf_practice_chat_flutter/features/topics/bloc/topics_loading_bloc.dart';
import 'package:surf_practice_chat_flutter/features/topics/scope/topics_screen_scope.dart';
import 'package:surf_practice_chat_flutter/features/topics/screens/create_topic_screen.dart';

class TopicsScreen extends StatelessWidget {
  final UserWithTokenDto userWithTokenDto;

  const TopicsScreen({
    required this.userWithTokenDto,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthorizedScope(
      userWithTokenDto: userWithTokenDto,
      child: TopicsScreenScope(
        child: Scaffold(
          appBar: const _TopicsAppBar(),
          body: SafeArea(
            child: OverscrollGlowDisabler(
              child: BlocBuilder<TopicsLoadingBloc, TopicsLoadingState>(
                builder: (context, state) {
                  return state.maybeMap<Widget>(
                    orElse: () {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    failed: (_) {
                      return const Center(
                        child: Text('Ошибка загрузки чатов'),
                      );
                    },
                    completed: (state) {
                      final chats = state.chats;

                      if (chats.isEmpty) {
                        return const Center(
                          child: Text('Список чатов пуст'),
                        );
                      }

                      return ListView.builder(
                        itemBuilder: (_, index) {
                          final chat = chats.elementAt(index);
                          final description = chat.description;

                          return ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Provider.value(
                                    value: AuthorizedScope.authorizedClient(context),
                                    child: ChatScreen(id: chat.id),
                                  ),
                                ),
                              );
                            },
                            title: Text(chat.name ?? '<Без названия>'),
                            subtitle: description != null
                                ? Text(
                                    description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : null,
                          );
                        },
                        itemCount: chats.length,
                      );
                    },
                  );
                },
              ),
            ),
          ),
          floatingActionButton: const _CreateTopicButton(),
        ),
      ),
    );
  }
}

class _TopicsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _TopicsAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              AuthorizedScope.authorizedUser(context).displayName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          AppIconButton(
            onPressed: () => TopicsScreenScope.loadTopics(context),
            tooltip: AppLocalizations.of(context).refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _CreateTopicButton extends StatelessWidget {
  const _CreateTopicButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Provider.value(
              value: AuthorizedScope.authorizedClient(context),
              child: const CreateTopicScreen(),
            ),
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }
}
