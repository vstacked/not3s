import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:not3s/core/error/failures.dart';
import 'package:not3s/features/auth/domain/entities/auth_entity.dart';
import 'package:not3s/features/auth/domain/usecases/login_usecase.dart';
import 'package:not3s/features/auth/domain/usecases/register_usecase.dart';
import 'package:not3s/features/auth/presentation/bloc/auth_bloc.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

// ── Helpers ───────────────────────────────────────────────────────────────────

const _tUsername = 'alice';
const _tPassword = 'secret123';
const _tEntity = AuthEntity(message: 'Login successful', token: 'a.b.c');

void main() {
  late MockLoginUseCase mockLogin;
  late MockRegisterUseCase mockRegister;

  setUpAll(() {
    registerFallbackValue(
        const LoginParams(username: '', password: ''));
    registerFallbackValue(
        const RegisterParams(username: '', password: ''));
  });

  setUp(() {
    mockLogin = MockLoginUseCase();
    mockRegister = MockRegisterUseCase();
  });

  AuthBloc _buildBloc() => AuthBloc(
        loginUseCase: mockLogin,
        registerUseCase: mockRegister,
      );

  // ── Initial state ─────────────────────────────────────────────────────────

  test('initial state is AuthInitial in login mode', () {
    final bloc = _buildBloc();
    expect(bloc.state, const AuthInitial());
    expect(bloc.state.mode, AuthMode.login);
  });

  // ── AuthModeChanged ───────────────────────────────────────────────────────

  group('AuthModeChanged', () {
    blocTest<AuthBloc, AuthState>(
      'switches to register mode',
      build: _buildBloc,
      act: (bloc) =>
          bloc.add(const AuthModeChanged(mode: AuthMode.register)),
      expect: () => [const AuthInitial(mode: AuthMode.register)],
    );

    blocTest<AuthBloc, AuthState>(
      'switches back to login mode from register mode',
      build: _buildBloc,
      seed: () => const AuthInitial(mode: AuthMode.register),
      act: (bloc) => bloc.add(const AuthModeChanged(mode: AuthMode.login)),
      expect: () => [const AuthInitial(mode: AuthMode.login)],
    );

    blocTest<AuthBloc, AuthState>(
      'emitting same mode still transitions to AuthInitial',
      build: _buildBloc,
      seed: () => const AuthFailure(
          mode: AuthMode.login, message: 'Bad credentials'),
      act: (bloc) => bloc.add(const AuthModeChanged(mode: AuthMode.login)),
      expect: () => [const AuthInitial(mode: AuthMode.login)],
    );
  });

  // ── AuthLoginRequested ────────────────────────────────────────────────────

  group('AuthLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] on successful login',
      build: () {
        when(() => mockLogin(any()))
            .thenAnswer((_) async => const Right(_tEntity));
        return _buildBloc();
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
          username: _tUsername, password: _tPassword)),
      expect: () => [
        const AuthLoading(mode: AuthMode.login),
        const AuthSuccess(mode: AuthMode.login, message: 'Login successful'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] on invalid credentials',
      build: () {
        when(() => mockLogin(any())).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'Invalid credentials')),
        );
        return _buildBloc();
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
          username: _tUsername, password: _tPassword)),
      expect: () => [
        const AuthLoading(mode: AuthMode.login),
        const AuthFailure(
            mode: AuthMode.login, message: 'Invalid credentials'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits generic network error message on NetworkFailure',
      build: () {
        when(() => mockLogin(any()))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return _buildBloc();
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
          username: _tUsername, password: _tPassword)),
      expect: () => [
        const AuthLoading(mode: AuthMode.login),
        const AuthFailure(
          mode: AuthMode.login,
          message: 'Network error. Please check your connection.',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'preserves mode when login is attempted in register mode',
      build: () {
        when(() => mockLogin(any()))
            .thenAnswer((_) async => const Right(_tEntity));
        return _buildBloc();
      },
      seed: () => const AuthInitial(mode: AuthMode.register),
      act: (bloc) => bloc.add(const AuthLoginRequested(
          username: _tUsername, password: _tPassword)),
      expect: () => [
        const AuthLoading(mode: AuthMode.register),
        const AuthSuccess(mode: AuthMode.register, message: 'Login successful'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'passes correct credentials to use case',
      build: () {
        when(() => mockLogin(any()))
            .thenAnswer((_) async => const Right(_tEntity));
        return _buildBloc();
      },
      act: (bloc) => bloc.add(
          const AuthLoginRequested(username: 'bob', password: 'hunter2')),
      verify: (_) {
        verify(() => mockLogin(
              const LoginParams(username: 'bob', password: 'hunter2'),
            )).called(1);
      },
    );
  });

  // ── AuthRegisterRequested ─────────────────────────────────────────────────

  group('AuthRegisterRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] on successful registration',
      build: () {
        when(() => mockRegister(any())).thenAnswer(
          (_) async => const Right('Account created successfully'),
        );
        return _buildBloc();
      },
      seed: () => const AuthInitial(mode: AuthMode.register),
      act: (bloc) => bloc.add(const AuthRegisterRequested(
          username: _tUsername, password: _tPassword)),
      expect: () => [
        const AuthLoading(mode: AuthMode.register),
        const AuthSuccess(
            mode: AuthMode.register,
            message: 'Account created successfully'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when username is already taken',
      build: () {
        when(() => mockRegister(any())).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'Username already taken')),
        );
        return _buildBloc();
      },
      seed: () => const AuthInitial(mode: AuthMode.register),
      act: (bloc) => bloc.add(const AuthRegisterRequested(
          username: _tUsername, password: _tPassword)),
      expect: () => [
        const AuthLoading(mode: AuthMode.register),
        const AuthFailure(
            mode: AuthMode.register, message: 'Username already taken'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits network error message on NetworkFailure during register',
      build: () {
        when(() => mockRegister(any()))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return _buildBloc();
      },
      seed: () => const AuthInitial(mode: AuthMode.register),
      act: (bloc) => bloc.add(const AuthRegisterRequested(
          username: _tUsername, password: _tPassword)),
      expect: () => [
        const AuthLoading(mode: AuthMode.register),
        const AuthFailure(
          mode: AuthMode.register,
          message: 'Network error. Please check your connection.',
        ),
      ],
    );

    // ── Edge cases ────────────────────────────────────────────────────────────

    blocTest<AuthBloc, AuthState>(
      'handles empty username in credentials (validation is the UI layer)',
      build: () {
        when(() => mockRegister(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Username required')),
        );
        return _buildBloc();
      },
      seed: () => const AuthInitial(mode: AuthMode.register),
      act: (bloc) =>
          bloc.add(const AuthRegisterRequested(username: '', password: 'pw')),
      expect: () => [
        const AuthLoading(mode: AuthMode.register),
        const AuthFailure(
            mode: AuthMode.register, message: 'Username required'),
      ],
    );
  });

  // ── State equality ────────────────────────────────────────────────────────

  group('State equality', () {
    test('AuthInitial with same mode are equal', () {
      expect(
        const AuthInitial(mode: AuthMode.login),
        const AuthInitial(mode: AuthMode.login),
      );
    });

    test('AuthFailure with same message and mode are equal', () {
      expect(
        const AuthFailure(mode: AuthMode.login, message: 'error'),
        const AuthFailure(mode: AuthMode.login, message: 'error'),
      );
    });

    test('AuthSuccess with same fields are equal', () {
      expect(
        const AuthSuccess(mode: AuthMode.login, message: 'ok'),
        const AuthSuccess(mode: AuthMode.login, message: 'ok'),
      );
    });
  });
}
