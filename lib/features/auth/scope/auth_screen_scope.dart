import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surf_practice_chat_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:surf_practice_chat_flutter/features/auth/bloc/auth_form_bloc.dart';
import 'package:surf_practice_chat_flutter/features/auth/models/token_dto.dart';
import 'package:surf_practice_chat_flutter/features/auth/repository/auth_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/screens/chat_screen.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

class AuthScreenScope extends StatelessWidget {
  final Widget child;

  const AuthScreenScope({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthFormBloc()),
        BlocProvider(
          create: (_) => AuthBloc(
            authRepository: AuthRepository(
              StudyJamClient(),
            ),
          ),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          state.mapOrNull(
            completed: (state) => _onUserSuccessfullySignedIn(context, state.tokenDto),
            failed: (state) => _onUserSignInFailed(context, state.message),
          );
        },
        child: child,
      ),
    );
  }

  void _onUserSuccessfullySignedIn(BuildContext context, TokenDto tokenDto) {
    Navigator.push<ChatScreen>(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(tokenDto: tokenDto),
      ),
    );
  }

  void _onUserSignInFailed(BuildContext context, String errorMsg) {
    ScaffoldMessenger.of(context).showSnackBar(
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

  static AuthFormBloc authFormBloc(BuildContext context) => context.read<AuthFormBloc>();

  static AuthBloc authBloc(BuildContext context) => context.read<AuthBloc>();

  static void setLogin(BuildContext context, String login) => authFormBloc(context).add(AuthFormEvent.setLogin(login));

  static void setPassword(BuildContext context, String password) =>
      authFormBloc(context).add(AuthFormEvent.setPassword(password));

  static void tryPerformSignIn(BuildContext context) {
    final form = authFormBloc(context).state;

    if (form.isValid) {
      authBloc(context).add(AuthEvent.performSignIn(
        login: form.login,
        password: form.password,
      ));
    }
  }
}
