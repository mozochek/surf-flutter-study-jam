import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:surf_practice_chat_flutter/features/auth/domain/models/user_with_token_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/presentation/chat_screen.dart';
import 'package:surf_practice_chat_flutter/features/core/presentation/l10n/app_localizations.dart';
import 'package:surf_practice_chat_flutter/features/core/presentation/scope/authorized_scope.dart';
import 'package:surf_practice_chat_flutter/features/core/presentation/widgets/app_icon_button.dart';
import 'package:surf_practice_chat_flutter/features/core/presentation/widgets/overscroll_glow_disabler.dart';
import 'package:surf_practice_chat_flutter/features/topics/features/all_topics/presentation/bloc/topics_loading_bloc.dart';
import 'package:surf_practice_chat_flutter/features/topics/features/all_topics/presentation/topics_screen_scope.dart';
import 'package:surf_practice_chat_flutter/features/topics/features/create_topic/presentation/create_topic_screen.dart';

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
                    orElse: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    failed: (_) => const _TopicsLoadingError(),
                    completed: (state) {
                      final chats = state.chats;

                      if (chats.isEmpty) {
                        return const _TopicsAreEmpty();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        itemBuilder: (_, index) {
                          final chat = chats.elementAt(index);
                          final description = chat.description;
                          final avatar = chat.avatar;

                          return Column(
                            children: <Widget>[
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
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
                                leading: ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(56.0)),
                                  child: SizedBox(
                                    width: 56.0,
                                    height: 56.0,
                                    child: avatar != null
                                        ? CachedNetworkImage(
                                            imageUrl: avatar,
                                            width: 56.0,
                                            height: 56.0,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: Colors.grey,
                                          ),
                                  ),
                                ),
                                title: Text(chat.name),
                                subtitle: description != null
                                    ? Text(
                                        description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : null,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 88.0),
                                child: Container(
                                  height: 1.0,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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

class _TopicsLoadingError extends StatelessWidget {
  const _TopicsLoadingError({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context).topicsLoadingError),
    );
  }
}

class _TopicsAreEmpty extends StatelessWidget {
  const _TopicsAreEmpty({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context).topicsAreEmpty),
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
