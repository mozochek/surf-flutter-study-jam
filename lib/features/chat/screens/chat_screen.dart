import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:surf_practice_chat_flutter/features/core/l10n/app_localizations.dart';
import 'package:surf_practice_chat_flutter/features/core/utils/color_utils.dart';
import 'package:surf_practice_chat_flutter/features/core/widgets/app_icon_button.dart';
import 'package:surf_practice_chat_flutter/features/core/widgets/keyboard_height_listener.dart';
import 'package:surf_practice_chat_flutter/features/core/widgets/overscroll_glow_disabler.dart';

class ChatScreen extends StatelessWidget {
  final TokenDto tokenDto;

  const ChatScreen({
    required this.tokenDto,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChatScreenScope(
      tokenDto: tokenDto,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: const _ChatAppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            OverscrollGlowDisabler(
              child: Expanded(
                child: BlocBuilder<MessagesLoadingBloc, MessagesLoadingState>(
                  builder: (context, state) {
                    return state.maybeMap<Widget>(
                      orElse: () {
                        return const _ChatsLoading();
                      },
                      completed: (state) {
                        final messages = state.messages;

                        if (messages.isEmpty) {
                          return const _EmptyMessages();
                        }

                        return _ChatMessagesList(messages: messages);
                      },
                      failed: (_) {
                        return const _MessagesLoadingError();
                      },
                    );
                  },
                ),
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
            tooltip: AppLocalizations.of(context).refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _ChatsLoading extends StatefulWidget {
  const _ChatsLoading({
    Key? key,
  }) : super(key: key);

  @override
  State<_ChatsLoading> createState() => _ChatsLoadingState();
}

class _ChatsLoadingState extends State<_ChatsLoading> {
  late final Random _random;
  late final Timer _timer;
  late final double _minHeight;
  late double _currentBaseHeight;

  @override
  void initState() {
    super.initState();

    _minHeight = 100.0;
    _currentBaseHeight = _minHeight;
    _random = Random();
    _timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) {
        if (mounted) {
          setState(() {
            _currentBaseHeight = _minHeight + _random.nextInt(25);
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(
          5,
          (index) {
            return _ChatMessagePlaceholder(height: _getRandomHeight());
          },
        ),
      ),
    );
  }

  double _getRandomHeight() {
    final shouldAdd = _random.nextBool();
    final value = _random.nextInt(35);

    return shouldAdd ? _currentBaseHeight + value : _currentBaseHeight - value;
  }
}

class _ChatMessagePlaceholder extends StatelessWidget {
  final double height;

  const _ChatMessagePlaceholder({
    this.height = 100.0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          const SizedBox(
            width: _MessageSenderAvatar._size,
            height: _MessageSenderAvatar._size,
            child: Material(
              color: Colors.white,
              shape: CircleBorder(),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Material(
              elevation: 2.0,
              borderRadius: const BorderRadius.all(Radius.circular(12.0)).copyWith(
                bottomLeft: Radius.zero,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12.0)).copyWith(
                  bottomLeft: Radius.zero,
                ),
                child: AnimatedContainer(
                  curve: Curves.easeInOutQuad,
                  duration: const Duration(milliseconds: 250),
                  height: height,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context).noMessages),
    );
  }
}

class _MessagesLoadingError extends StatelessWidget {
  const _MessagesLoadingError({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context).messagesLoadingError),
    );
  }
}

class _ChatMessagesList extends StatefulWidget {
  final Iterable<ChatMessageDto> messages;

  const _ChatMessagesList({
    required this.messages,
    Key? key,
  }) : super(key: key);

  @override
  State<_ChatMessagesList> createState() => _ChatMessagesListState();
}

class _ChatMessagesListState extends State<_ChatMessagesList> {
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
      child: FlutterListView(
        controller: _scrollController,
        delegate: FlutterListViewDelegate(
          (context, index) {
            final currentMessage = widget.messages.elementAt(index);
            final previousMessage = index < widget.messages.length - 1 ? widget.messages.elementAt(index + 1) : null;

            final nextIsTheSameUser = previousMessage?.chatUserDto.id == currentMessage.chatUserDto.id;

            return _ChatMessage(
              messageData: currentMessage,
              nextIsTheSameUser: nextIsTheSameUser,
            );
          },
          childCount: widget.messages.length,
          initIndex: widget.messages.length - 1,
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

class _ChatTextField extends StatefulWidget {
  const _ChatTextField({
    Key? key,
  }) : super(key: key);

  @override
  State<_ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<_ChatTextField> {
  late final TextEditingController _messageTextController;
  late final AppLocalizations _l10n;

  @override
  void initState() {
    super.initState();

    _messageTextController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _l10n = AppLocalizations.of(context);
  }

  @override
  void dispose() {
    _messageTextController.dispose();

    super.dispose();
  }

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
              child: BlocListener<CurrentMessageBloc, CurrentMessageState>(
                listenWhen: (prev, curr) => prev.text != curr.text,
                listener: (context, state) {
                  final text = state.text ?? '';

                  _messageTextController.value = TextEditingValue(
                    text: text,
                    selection: TextSelection.fromPosition(TextPosition(offset: text.length)),
                  );
                },
                child: TextFormField(
                  maxLines: null,
                  controller: _messageTextController,
                  keyboardType: TextInputType.multiline,
                  onChanged: (text) => ChatScreenScope.setMessageText(context, text),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: _l10n.message,
                  ),
                ),
              ),
            ),
            BlocBuilder<CurrentMessageBloc, CurrentMessageState>(
              buildWhen: (prev, curr) => prev.text != curr.text,
              builder: (context, state) {
                final text = state.text;

                if (text == null || text.isEmpty) {
                  return Row(
                    children: const <Widget>[
                      _AttachGeoPointIcon(),
                      _PickImagesIcon(),
                    ],
                  );
                }

                return const _SendMessageIcon();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachGeoPointIcon extends StatelessWidget {
  const _AttachGeoPointIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      icon: const Icon(Icons.location_on_outlined),
      onPressed: () {},
      tooltip: AppLocalizations.of(context).addGeoPoint,
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
  late final AppLocalizations _l10n;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _l10n = AppLocalizations.of(context);
  }

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
      tooltip: _l10n.attach,
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
      tooltip: AppLocalizations.of(context).send,
      icon: const Icon(Icons.send),
    );
  }
}

class _ChatMessage extends StatelessWidget {
  final ChatMessageDto messageData;
  final bool nextIsTheSameUser;

  const _ChatMessage({
    required this.messageData,
    required this.nextIsTheSameUser,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMessageSentByThisUser = messageData.chatUserDto is ChatUserLocalDto;
    final text = messageData.text;
    final coords = messageData.coords;
    final images = messageData.images;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          isMessageSentByThisUser
              ? const SizedBox(width: _MessageSenderAvatar._size)
              : nextIsTheSameUser
                  ? const SizedBox(width: _MessageSenderAvatar._size)
                  : _MessageSenderAvatar(userData: messageData.chatUserDto),
          const SizedBox(width: 16.0),
          Expanded(
            child: Material(
              elevation: 2.0,
              color: isMessageSentByThisUser ? Colors.greenAccent.shade100 : null,
              borderRadius: isMessageSentByThisUser
                  ? const BorderRadius.all(Radius.circular(12.0)).copyWith(bottomRight: Radius.zero)
                  : const BorderRadius.all(Radius.circular(12.0)).copyWith(bottomLeft: Radius.zero),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            messageData.chatUserDto.displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (images != null && images.isNotEmpty) ...[
                          const SizedBox(height: 4.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: _MessageImagesPreview(imageUrls: images),
                          ),
                          const SizedBox(height: 8.0),
                        ],
                        if (text != null && text.isNotEmpty) ...[
                          const SizedBox(height: 4.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(text),
                          ),
                          const SizedBox(height: 8.0),
                        ],
                        if (coords != null) ...[
                          Align(
                            alignment: Alignment.centerRight,
                            child: _OpenMapIcon(coords: coords),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageSenderAvatar extends StatelessWidget {
  static const _size = 42.0;

  final ChatUserDto userData;

  const _MessageSenderAvatar({
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

class _MessageImagesPreview extends StatelessWidget {
  final List<String> imageUrls;

  const _MessageImagesPreview({
    required this.imageUrls,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrls.length == 1) {
      return _RoundedNetworkImage(imgUrl: imageUrls.first);
    }

    if (imageUrls.length == 2) {
      return SizedBox(
        height: 128.0,
        child: Row(
          children: <Widget>[
            Expanded(
              child: _RoundedNetworkImage(imgUrl: imageUrls.first),
            ),
            const SizedBox(width: 4.0),
            Expanded(
              child: _RoundedNetworkImage(imgUrl: imageUrls.last),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 128.0,
      child: Row(
        children: <Widget>[
          Expanded(
            child: _RoundedNetworkImage(
              imgUrl: imageUrls.first,
            ),
          ),
          const SizedBox(width: 4.0),
          Expanded(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: _RoundedNetworkImage(
                          imgUrl: imageUrls.last,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // TODO: просмотр фоток
                      print('должны открыться все фотки');
                    },
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                      child: Stack(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: _RoundedNetworkImage(
                                  imgUrl: imageUrls[2],
                                ),
                              ),
                            ],
                          ),
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaY: 2.5, sigmaX: 2.5),
                            child: Center(
                              child: Text(
                                '+${imageUrls.length - 2}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundedNetworkImage extends StatelessWidget {
  final String imgUrl;

  const _RoundedNetworkImage({
    required this.imgUrl,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      child: SizedBox(
        height: 128.0,
        child: CachedNetworkImage(
          imageUrl: imgUrl,
          height: 128.0,
          fit: BoxFit.fill,
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
    final l10n = AppLocalizations.of(context);

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
                title: l10n.attachedGeoPoint,
                zoom: coords.zoom?.toInt(),
              );
            },
          ),
        );
      },
      tooltip: l10n.onTheMap,
      icon: const Icon(
        Icons.map_outlined,
        color: Colors.grey,
        size: 16.0,
      ),
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
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(AppLocalizations.of(context).mapAppsNotFound),
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
