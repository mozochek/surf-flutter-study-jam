import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_form_bloc.freezed.dart';

class LoginFormBloc extends Bloc<LoginFormEvent, LoginFormState> {
  LoginFormBloc() : super(const LoginFormState()) {
    on<LoginFormEvent>(
      (event, emit) => event.map(
        setLogin: (event) => _onSetLogin(event, emit),
        setPassword: (event) => _onSetPassword(event, emit),
      ),
    );
  }

  void _onSetLogin(_LoginFormEventSetLogin event, Emitter<LoginFormState> emit) {
    emit(state.copyWith(login: event.login));
  }

  void _onSetPassword(_LoginFormEventSetPassword event, Emitter<LoginFormState> emit) {
    emit(state.copyWith(password: event.password));
  }
}

@freezed
class LoginFormEvent with _$LoginFormEvent {
  const LoginFormEvent._();

  const factory LoginFormEvent.setLogin(String login) = _LoginFormEventSetLogin;

  const factory LoginFormEvent.setPassword(String password) = _LoginFormEventSetPassword;
}

@freezed
class LoginFormState with _$LoginFormState {
  const LoginFormState._();

  const factory LoginFormState({
    @Default('') String login,
    @Default('') String password,
  }) = _LoginFormState;

  bool get isValid => login.isNotEmpty && password.isNotEmpty;
}
