import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surf_practice_chat_flutter/features/auth/data/repository/auth_repository.dart';
import 'package:surf_practice_chat_flutter/features/auth/domain/models/user_with_token_dto.dart';
import 'package:surf_practice_chat_flutter/features/auth/features/login/presentation/bloc/login_bloc.dart';
import 'package:surf_practice_chat_flutter/features/auth/features/login/presentation/bloc/login_form_bloc.dart';
import 'package:surf_practice_chat_flutter/features/chat/presentation/chat_screen.dart';
import 'package:surf_practice_chat_flutter/features/topics/features/all_topics/presentation/topics_screen.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

class LoginScreenScope extends StatelessWidget {
  final Widget child;

  const LoginScreenScope({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LoginFormBloc()),
        BlocProvider(
          create: (_) => LoginBloc(
            authRepository: AuthRepository(
              StudyJamClient(),
            ),
          ),
        ),
      ],
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          state.mapOrNull(
            completed: (state) => _onUserSuccessfullySignedIn(context, state.userWithTokenDto),
            failed: (state) => _onUserSignInFailed(context, state.message),
          );
        },
        child: child,
      ),
    );
  }

  void _onUserSuccessfullySignedIn(BuildContext context, UserWithTokenDto userWithTokenDto) {
    Navigator.push<ChatScreen>(
      context,
      MaterialPageRoute(
        builder: (_) => TopicsScreen(userWithTokenDto: userWithTokenDto),
      ),
    );
  }

  void _onUserSignInFailed(BuildContext context, String errorMsg) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.warning, color: Colors.redAccent),
              const SizedBox(width: 8.0),
              Text(errorMsg),
            ],
          ),
        ),
      );
  }

  static LoginFormBloc authFormBloc(BuildContext context) => context.read<LoginFormBloc>();

  static LoginBloc authBloc(BuildContext context) => context.read<LoginBloc>();

  static void setLogin(BuildContext context, String login) => authFormBloc(context).add(LoginFormEvent.setLogin(login));

  static void setPassword(BuildContext context, String password) =>
      authFormBloc(context).add(LoginFormEvent.setPassword(password));

  static void tryPerformSignIn(BuildContext context) {
    final form = authFormBloc(context).state;

    if (form.isValid) {
      authBloc(context).add(LoginEvent.performSignIn(
        login: form.login,
        password: form.password,
      ));
    }
  }
}
