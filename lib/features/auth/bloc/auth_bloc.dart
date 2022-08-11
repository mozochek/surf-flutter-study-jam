import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:surf_practice_chat_flutter/features/auth/exceptions/auth_exception.dart';
import 'package:surf_practice_chat_flutter/features/auth/models/token_dto.dart';
import 'package:surf_practice_chat_flutter/features/auth/repository/auth_repository.dart';

part 'auth_bloc.freezed.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _authRepository;

  AuthBloc({
    required IAuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthState.notInitialized()) {
    on<AuthEvent>(
      (event, emit) async => event.map(
        performSignIn: (event) => _onPerformSignIn(event, emit),
      ),
      transformer: bloc_concurrency.droppable(),
    );
  }

  Future<void> _onPerformSignIn(_AuthEventPerformSignIn event, Emitter<AuthState> emit) async {
    try {
      emit(const AuthState.inProgress());

      final tokenDto = await _authRepository.signIn(
        login: event.login,
        password: event.password,
      );

      emit(AuthState.completed(tokenDto));
    } on Object catch (e) {
      if (e is AuthException) {
        emit(AuthState.failed(e.message));
        return;
      }

      emit(const AuthState.failed('Unknown error.'));
      rethrow;
    }
  }
}

@freezed
class AuthEvent with _$AuthEvent {
  const AuthEvent._();

  const factory AuthEvent.performSignIn({
    required String login,
    required String password,
  }) = _AuthEventPerformSignIn;
}

@freezed
class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState.notInitialized() = _AuthStateNotInitialized;

  const factory AuthState.inProgress() = _AuthStateInProgress;

  const factory AuthState.completed(TokenDto tokenDto) = _AuthStateCompleted;

  const factory AuthState.failed(String message) = _AuthStateFailed;
}
