import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surf_practice_chat_flutter/features/core/presentation/l10n/app_localizations.dart';
import 'package:surf_practice_chat_flutter/features/topics/features/create_topic/presentation/bloc/topic_creator_bloc.dart';
import 'package:surf_practice_chat_flutter/features/topics/features/create_topic/presentation/create_topic_screen_scope.dart';

class CreateTopicScreen extends StatelessWidget {
  const CreateTopicScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CreateTopicScreenScope(
      child: Scaffold(
        appBar: const _AppBar(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: const <Widget>[
                SizedBox(height: 16.0),
                _TopicTitleTextField(),
                SizedBox(height: 16.0),
                _TopicDescriptionTextField(),
                SizedBox(height: 16.0),
                _CreateTopicButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(AppLocalizations.of(context).topicCreating),
    );
  }
}

class _TopicTitleTextField extends StatelessWidget {
  const _TopicTitleTextField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: true,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onChanged: (title) => CreateTopicScreenScope.setTopicTitle(context, title),
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: AppLocalizations.of(context).title,
      ),
    );
  }
}

class _TopicDescriptionTextField extends StatelessWidget {
  const _TopicDescriptionTextField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.go,
      onFieldSubmitted: (_) => CreateTopicScreenScope.tryToCreateTopic(context),
      onChanged: (description) => CreateTopicScreenScope.setTopicDescription(context, description),
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: AppLocalizations.of(context).description,
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
    return Row(
      children: <Widget>[
        Expanded(
          child: BlocBuilder<TopicCreatorBloc, TopicCreatorState>(
            buildWhen: (prev, curr) => prev.isInProgress != curr.isInProgress,
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state.isInProgress ? null : () => CreateTopicScreenScope.tryToCreateTopic(context),
                child: Text(AppLocalizations.of(context).create.toUpperCase()),
              );
            },
          ),
        ),
      ],
    );
  }
}
