import 'package:flutter/material.dart';
import 'package:surf_practice_chat_flutter/features/topics/scope/create_topic_screen_scope.dart';

class CreateTopicScreen extends StatelessWidget {
  const CreateTopicScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CreateTopicScreenScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Создание чата'),
        ),
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

class _TopicTitleTextField extends StatelessWidget {
  const _TopicTitleTextField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: (title) => CreateTopicScreenScope.setTopicTitle(context, title),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Название чата',
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
      onChanged: (description) => CreateTopicScreenScope.setTopicDescription(context, description),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Описание',
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
          child: ElevatedButton(
            onPressed: () => CreateTopicScreenScope.tryToCreateTopic(context),
            child: Text('Создать'.toUpperCase()),
          ),
        ),
      ],
    );
  }
}
