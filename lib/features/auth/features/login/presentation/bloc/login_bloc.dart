import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:surf_practice_chat_flutter/features/auth/data/exceptions/auth_exception.dart';
import 'package:surf_practice_chat_flutter/features/auth/domain/models/user_with_token_dto.dart';
import 'package:surf_practice_chat_flutter/features/auth/domain/repository/i_auth_repository.dart';

part 'login_bloc.freezed.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final IAuthRepository _authRepository;

  LoginBloc({
    required IAuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const LoginState.notInitialized()) {
    on<LoginEvent>(
      (event, emit) async => event.map(
        performSignIn: (event) => _onPerformSignIn(event, emit),
      ),
      transformer: bloc_concurrency.droppable(),
    );
  }

  Future<void> _onPerformSignIn(_LoginEventPerformSignIn event, Emitter<LoginState> emit) async {
    try {
      emit(const LoginState.inProgress());

      final userWithTokenDto = await _authRepository.signIn(
        login: event.login,
        password: event.password,
      );

      emit(LoginState.completed(userWithTokenDto));
    } on Object catch (e) {
      if (e is AuthException) {
        emit(LoginState.failed(e.message));
        return;
      }

      emit(const LoginState.failed('Unknown error.'));
      rethrow;
    }
  }
}

@freezed
class LoginEvent with _$LoginEvent {
  const LoginEvent._();

  const factory LoginEvent.performSignIn({
    required String login,
    required String password,
  }) = _LoginEventPerformSignIn;
}

@freezed
class LoginState with _$LoginState {
  const LoginState._();

  const factory LoginState.notInitialized() = _LoginStateNotInitialized;

  const factory LoginState.inProgress() = _LoginStateInProgress;

  const factory LoginState.completed(UserWithTokenDto userWithTokenDto) = _LoginStateCompleted;

  const factory LoginState.failed(String message) = _LoginStateFailed;

  bool get isInProgress => maybeMap(
        orElse: () => false,
        inProgress: (_) => true,
      );
}
