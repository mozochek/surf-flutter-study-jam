import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surf_practice_chat_flutter/features/auth/features/login/presentation/bloc/login_bloc.dart';
import 'package:surf_practice_chat_flutter/features/auth/features/login/presentation/login_screen_scope.dart';
import 'package:surf_practice_chat_flutter/features/core/presentation/l10n/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginScreenScope(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                _LoginTextField(),
                SizedBox(height: 8.0),
                _PasswordTextField(),
                SizedBox(height: 8.0),
                _LoginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginTextField extends StatelessWidget {
  const _LoginTextField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: true,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      onChanged: (login) => LoginScreenScope.setLogin(context, login),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).login,
        prefixIcon: const Icon(Icons.person),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _PasswordTextField extends StatelessWidget {
  const _PasswordTextField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.go,
      keyboardType: TextInputType.visiblePassword,
      onFieldSubmitted: (_) => LoginScreenScope.tryPerformSignIn(context),
      onChanged: (password) => LoginScreenScope.setPassword(context, password),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).password,
        prefixIcon: const Icon(Icons.lock),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: BlocBuilder<LoginBloc, LoginState>(
            buildWhen: (prev, curr) => prev.isInProgress != curr.isInProgress,
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state.isInProgress ? null : () => LoginScreenScope.tryPerformSignIn(context),
                child: Text(AppLocalizations.of(context).onward.toUpperCase()),
              );
            },
          ),
        ),
      ],
    );
  }
}
