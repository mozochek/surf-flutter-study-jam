import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:surf_practice_chat_flutter/features/auth/models/token_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/bloc/current_message_bloc.dart';
import 'package:surf_practice_chat_flutter/features/chat/bloc/messages_loading_bloc.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_message_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_local_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/send_message_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/scope/chat_screen_scope.dart';
import 'package:surf_practice_chat_flutter/features/core/utils/color_utils.dart';
import 'package:surf_practice_chat_flutter/features/core/widgets/app_icon_button.dart';
import 'package:surf_practice_chat_flutter/features/core/widgets/keyboard_height_listener.dart';

// TODO: рефакторинг и вынесение локализации
class ChatScreen extends StatelessWidget {
  final TokenDto tokenDto;

  const ChatScreen({
    required this.tokenDto,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChatScreenScope(
      tokenDto: tokenDto,
      child: Scaffold(
        backgroundColor: colorScheme.background,
        appBar: const _ChatAppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: BlocBuilder<MessagesLoadingBloc, MessagesLoadingState>(
                builder: (context, state) {
                  return state.maybeMap<Widget>(
                    orElse: () {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    completed: (state) {
                      final messages = state.messages;

                      if (messages.isEmpty) {
                        return const Center(
                          child: Text('Сообщений нет'),
                        );
                      }

                      return _ChatBody(messages: messages);
                    },
                    failed: (_) {
                      return const Center(
                        child: Text('Произошла ошибка загрузки сообщений'),
                      );
                    },
                  );
                },
              ),
            ),
            const _MessageAttachedImages(),
            const _ChatTextField(),
          ],
        ),
      ),
    );
  }
}

class _ChatBody extends StatefulWidget {
  final Iterable<ChatMessageDto> messages;

  const _ChatBody({
    required this.messages,
    Key? key,
  }) : super(key: key);

  @override
  State<_ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<_ChatBody> {
  late final FlutterListViewController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = FlutterListViewController();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardHeightChangesListener(
      onKeyboardHeightChanged: (keyboardHeight, heightDiff) {
        final maxExtent = _scrollController.position.maxScrollExtent;
        final currentOffset = _scrollController.offset;
        final calculatedOffset = currentOffset + heightDiff;

        _scrollController.jumpTo(max(min(maxExtent, calculatedOffset), calculatedOffset));
      },
      child: NotificationListener(
        onNotification: (notification) {
          if (notification is OverscrollIndicatorNotification) {
            notification.disallowIndicator();
          }

          return false;
        },
        child: FlutterListView(
          controller: _scrollController,
          delegate: FlutterListViewDelegate(
            (context, index) {
              final currentMessage = widget.messages.elementAt(index);
              final previousMessage = index < widget.messages.length - 1 ? widget.messages.elementAt(index + 1) : null;

              final nextIsTheSameUser = previousMessage?.chatUserDto.id == currentMessage.chatUserDto.id;

              return _ChatMessage(
                chatData: currentMessage,
                nextIsTheSameUser: nextIsTheSameUser,
              );
            },
            childCount: widget.messages.length,
            initIndex: widget.messages.length - 1,
          ),
        ),
      ),
    );
  }
}

class _MessageAttachedImages extends StatelessWidget {
  const _MessageAttachedImages({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentMessageBloc, CurrentMessageState>(
      buildWhen: (prev, curr) => prev.images != curr.images,
      builder: (context, state) {
        final images = state.images;

        if (images == null) return const SizedBox.shrink();

        return Row(
          children: List.generate(
            images.length,
            (index) {
              final int itemIndex = index ~/ 2;

              if (itemIndex.isEven) {
                return Image.file(
                  File.fromUri(Uri.file(images.elementAt(index))),
                  width: 56.0,
                  height: 56.0,
                );
              }

              return const SizedBox(width: 8.0);
            },
          ),
        );
      },
    );
  }
}

class _ChatTextField extends StatelessWidget {
  const _ChatTextField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      elevation: 6.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                onChanged: (text) => ChatScreenScope.setMessageText(context, text),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Сообщение',
                ),
              ),
            ),
            BlocBuilder<CurrentMessageBloc, CurrentMessageState>(
              buildWhen: (prev, curr) => prev.text != curr.text,
              builder: (context, state) {
                final text = state.text;

                if (text == null || text.isEmpty) return const _PickImagesIcon();

                return const _SendMessageIcon();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PickImagesIcon extends StatefulWidget {
  const _PickImagesIcon({
    Key? key,
  }) : super(key: key);

  @override
  _PickImagesIconState createState() => _PickImagesIconState();
}

class _PickImagesIconState extends State<_PickImagesIcon> {
  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      onPressed: () async {
        final result = await FilePicker.platform.pickFiles(type: FileType.image);

        if (mounted && result != null) {
          final validPaths = result.paths.whereType<String>();
          ChatScreenScope.addImages(context, validPaths);
        }
      },
      tooltip: 'Прикрепить',
      icon: const Icon(Icons.attach_file),
    );
  }
}

class _SendMessageIcon extends StatelessWidget {
  const _SendMessageIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      onPressed: () => ChatScreenScope.tryToSendCurrentMessage(context),
      tooltip: 'Отправить',
      icon: const Icon(Icons.send),
    );
  }
}

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          AppIconButton(
            onPressed: () => ChatScreenScope.loadMessages(context),
            tooltip: 'Обновить',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage extends StatelessWidget {
  final ChatMessageDto chatData;
  final bool nextIsTheSameUser;

  const _ChatMessage({
    required this.chatData,
    required this.nextIsTheSameUser,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMessageSentByThisUser = chatData.chatUserDto is ChatUserLocalDto;
    final coords = chatData.coords;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          isMessageSentByThisUser
              ? const SizedBox(width: _ChatAvatar._size)
              : nextIsTheSameUser
                  ? const SizedBox(width: _ChatAvatar._size)
                  : _ChatAvatar(userData: chatData.chatUserDto),
          const SizedBox(width: 16.0),
          Expanded(
            child: Material(
              elevation: 2.0,
              color: isMessageSentByThisUser ? Colors.greenAccent : null,
              borderRadius: isMessageSentByThisUser
                  ? const BorderRadius.all(Radius.circular(16.0)).copyWith(bottomRight: Radius.zero)
                  : const BorderRadius.all(Radius.circular(16.0)).copyWith(bottomLeft: Radius.zero),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            chatData.chatUserDto.name ?? '<Unnamed user>',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4.0),
                          Text(chatData.text ?? '<empty msg>'),
                        ],
                      ),
                    ),
                    if (coords != null) ...[
                      _OpenMapIcon(coords: coords),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  static const _size = 42.0;

  final ChatUserDto userData;

  const _ChatAvatar({
    required this.userData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: _size,
      height: _size,
      child: Material(
        color: ColorUtils.stringToColor('$userData'),
        shape: const CircleBorder(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FittedBox(
              child: Text(
                userData.initials,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OpenMapIcon extends StatelessWidget {
  final LatLng coords;

  const _OpenMapIcon({
    required this.coords,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      onPressed: () async {
        final availableMaps = await MapLauncher.installedMaps;

        showModalBottomSheet(
          context: context,
          builder: (_) => _AvailableMapAppsBottomSheet(
            availableMaps: availableMaps,
            onMapSelected: (map) async {
              await map.showMarker(
                coords: Coords(coords.latitude, coords.longitude),
                title: 'Отправлено отсюда',
                zoom: coords.zoom?.toInt(),
              );
            },
          ),
        );
      },
      tooltip: 'Подглядеть за отправителем',
      icon: const Icon(Icons.map),
    );
  }
}

typedef OnMapSelected = void Function(AvailableMap);

class _AvailableMapAppsBottomSheet extends StatelessWidget {
  final List<AvailableMap> availableMaps;
  final OnMapSelected onMapSelected;

  const _AvailableMapAppsBottomSheet({
    required this.availableMaps,
    required this.onMapSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (availableMaps.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Не найдены приложения с картами'),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Wrap(
          children: <Widget>[
            for (var map in availableMaps)
              ListTile(
                onTap: () => onMapSelected(map),
                title: Text(map.mapName),
                leading: SvgPicture.asset(
                  map.icon,
                  height: 30.0,
                  width: 30.0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
