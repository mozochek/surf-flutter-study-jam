import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_form_bloc.freezed.dart';

class AuthFormBloc extends Bloc<AuthFormEvent, AuthFormState> {
  AuthFormBloc() : super(const AuthFormState()) {
    on<AuthFormEvent>(
      (event, emit) => event.map(
        setLogin: (event) => _onSetLogin(event, emit),
        setPassword: (event) => _onSetPassword(event, emit),
      ),
    );
  }

  void _onSetLogin(_AuthFormEventSetLogin event, Emitter<AuthFormState> emit) {
    emit(state.copyWith(login: event.login));
  }

  void _onSetPassword(_AuthFormEventSetPassword event, Emitter<AuthFormState> emit) {
    emit(state.copyWith(password: event.password));
  }
}

@freezed
class AuthFormEvent with _$AuthFormEvent {
  const AuthFormEvent._();

  const factory AuthFormEvent.setLogin(String login) = _AuthFormEventSetLogin;

  const factory AuthFormEvent.setPassword(String password) = _AuthFormEventSetPassword;
}

@freezed
class AuthFormState with _$AuthFormState {
  const AuthFormState._();

  const factory AuthFormState({
    @Default('') String login,
    @Default('') String password,
  }) = _AuthFormState;

  bool get isValid => login.isNotEmpty && password.isNotEmpty;
}
