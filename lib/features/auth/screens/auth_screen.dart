import 'package:flutter/material.dart';
import 'package:surf_practice_chat_flutter/features/auth/scope/auth_screen_scope.dart';
import 'package:surf_practice_chat_flutter/features/core/l10n/app_localizations.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthScreenScope(
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
      onChanged: (login) => AuthScreenScope.setLogin(context, login),
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
      onChanged: (password) => AuthScreenScope.setPassword(context, password),
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
          child: ElevatedButton(
            onPressed: () => AuthScreenScope.tryPerformSignIn(context),
            child: Text(AppLocalizations.of(context).onward.toUpperCase()),
          ),
        ),
      ],
    );
  }
}
