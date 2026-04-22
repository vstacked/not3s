/// Integration tests for the Notes feature.
///
/// These tests boot the real [NotesPage] widget but replace the DI container
/// with mock use cases, so no network or database is required.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:not3s/core/error/failures.dart';
import 'package:not3s/core/storage/storage_service.dart';
import 'package:not3s/core/styles/app_theme.dart';
import 'package:not3s/core/usecases/usecase.dart';
import 'package:not3s/features/notes/domain/entities/note_entity.dart';
import 'package:not3s/features/notes/domain/usecases/create_note_usecase.dart';
import 'package:not3s/features/notes/domain/usecases/delete_note_usecase.dart';
import 'package:not3s/features/notes/domain/usecases/get_notes_usecase.dart';
import 'package:not3s/features/notes/domain/usecases/update_note_usecase.dart';
import 'package:not3s/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:not3s/features/notes/presentation/pages/notes_page.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockGetNotesUseCase extends Mock implements GetNotesUseCase {}

class MockCreateNoteUseCase extends Mock implements CreateNoteUseCase {}

class MockUpdateNoteUseCase extends Mock implements UpdateNoteUseCase {}

class MockDeleteNoteUseCase extends Mock implements DeleteNoteUseCase {}

class MockStorageService extends Mock implements StorageService {}

// ── Test data ─────────────────────────────────────────────────────────────────

final _note1 = NoteEntity(
  id: 1,
  title: 'First Note',
  content: 'Some content here',
  updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
);
final _note2 = NoteEntity(
  id: 2,
  title: 'Second Note',
  content: 'Other content here',
  updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
);
final _testNotes = [_note1, _note2];

// ── Setup helpers ─────────────────────────────────────────────────────────────

final _sl = GetIt.instance;

late MockGetNotesUseCase _mockGetNotes;
late MockCreateNoteUseCase _mockCreateNote;
late MockUpdateNoteUseCase _mockUpdateNote;
late MockDeleteNoteUseCase _mockDeleteNote;
late MockStorageService _mockStorage;

void _registerFakes() {
  registerFallbackValue(const NoParams());
  registerFallbackValue(const CreateNoteParams(title: '', content: ''));
  registerFallbackValue(const DeleteNoteParams(id: 0));
  registerFallbackValue(const UpdateNoteParams(id: 0, title: '', content: ''));
}

Future<void> _setupMockDI() async {
  _mockGetNotes = MockGetNotesUseCase();
  _mockCreateNote = MockCreateNoteUseCase();
  _mockUpdateNote = MockUpdateNoteUseCase();
  _mockDeleteNote = MockDeleteNoteUseCase();
  _mockStorage = MockStorageService();

  _sl.registerFactory<NotesBloc>(
    () => NotesBloc(
      getNotesUseCase: _mockGetNotes,
      createNoteUseCase: _mockCreateNote,
      updateNoteUseCase: _mockUpdateNote,
      deleteNoteUseCase: _mockDeleteNote,
    ),
  );
  _sl.registerSingleton<StorageService>(_mockStorage);
}

Widget _buildApp() => MaterialApp(
      theme: appTheme,
      home: const NotesPage(),
      routes: {
        '/welcome': (_) => const Scaffold(body: Text('Welcome')),
      },
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_registerFakes);

  setUp(() async {
    await _sl.reset(dispose: false);
    await _setupMockDI();
  });

  // ── Loading state ─────────────────────────────────────────────────────────

  testWidgets('shows loading indicator while fetching notes', (tester) async {
    // Never resolves immediately — simulates slow network
    when(() => _mockGetNotes(any())).thenAnswer(
      (_) async {
        await Future<void>.delayed(const Duration(seconds: 5));
        return Right(_testNotes);
      },
    );

    await tester.pumpWidget(_buildApp());
    await tester.pump(); // allow initial render + bloc event dispatch

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // ── Notes list ────────────────────────────────────────────────────────────

  testWidgets('renders all notes after successful load', (tester) async {
    when(() => _mockGetNotes(any()))
        .thenAnswer((_) async => Right(_testNotes));

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.text('First Note'), findsOneWidget);
    expect(find.text('Second Note'), findsOneWidget);
  });

  // ── Empty state ───────────────────────────────────────────────────────────

  testWidgets('shows empty-state widget when no notes exist', (tester) async {
    when(() => _mockGetNotes(any()))
        .thenAnswer((_) async => const Right([]));

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.text('No notes yet'), findsOneWidget);
    expect(find.text('Tap + to create your first note'), findsOneWidget);
  });

  // ── Error state ───────────────────────────────────────────────────────────

  testWidgets('shows error snackbar when load fails', (tester) async {
    when(() => _mockGetNotes(any())).thenAnswer(
      (_) async =>
          const Left(ServerFailure(message: 'Server unavailable')),
    );

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Server unavailable'), findsOneWidget);
  });

  testWidgets('shows generic error message on network failure', (tester) async {
    when(() => _mockGetNotes(any()))
        .thenAnswer((_) async => const Left(NetworkFailure()));

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Network error. Please check your connection.'),
        findsOneWidget);
  });

  // ── Search ────────────────────────────────────────────────────────────────

  testWidgets('filters notes by title as user types', (tester) async {
    when(() => _mockGetNotes(any()))
        .thenAnswer((_) async => Right(_testNotes));

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    // Type into the search bar (the only visible TextField before sheet opens)
    await tester.enterText(find.byType(TextField).first, 'First');
    await tester.pump();

    expect(find.text('First Note'), findsOneWidget);
    expect(find.text('Second Note'), findsNothing);
  });

  testWidgets('shows no-results empty state when search yields nothing',
      (tester) async {
    when(() => _mockGetNotes(any()))
        .thenAnswer((_) async => Right(_testNotes));

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'xyz-no-match');
    await tester.pump();

    expect(find.text('No results found'), findsOneWidget);
    expect(find.text('Try a different keyword'), findsOneWidget);
  });

  testWidgets('restores full list when search is cleared', (tester) async {
    when(() => _mockGetNotes(any()))
        .thenAnswer((_) async => Right(_testNotes));

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    // Filter
    await tester.enterText(find.byType(TextField).first, 'First');
    await tester.pump();
    expect(find.text('Second Note'), findsNothing);

    // Clear via the X button
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(find.text('First Note'), findsOneWidget);
    expect(find.text('Second Note'), findsOneWidget);
  });

  // ── Create note ───────────────────────────────────────────────────────────

  testWidgets('opens New Note sheet when FAB is tapped', (tester) async {
    when(() => _mockGetNotes(any()))
        .thenAnswer((_) async => Right(_testNotes));

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('New Note'), findsOneWidget);
    expect(find.text('Create Note'), findsOneWidget);
  });

  testWidgets('creates a note and reloads list', (tester) async {
    when(() => _mockGetNotes(any()))
        .thenAnswer((_) async => Right(_testNotes));
    when(() => _mockCreateNote(any()))
        .thenAnswer((_) async => const Right('created'));

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    // Open sheet
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Title field is index 1 (index 0 = search bar), content is index 2
    await tester.enterText(find.byType(TextField).at(1), 'Integration Title');
    await tester.enterText(find.byType(TextField).at(2), 'Integration Content');
    await tester.tap(find.text('Create Note'));
    await tester.pumpAndSettle();

    verify(() => _mockCreateNote(const CreateNoteParams(
          title: 'Integration Title',
          content: 'Integration Content',
        ))).called(1);

    // Sheet dismissed
    expect(find.text('New Note'), findsNothing);
  });

  testWidgets('does not create note when title or content is empty',
      (tester) async {
    when(() => _mockGetNotes(any()))
        .thenAnswer((_) async => Right(_testNotes));

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Tap create with no input
    await tester.tap(find.text('Create Note'));
    await tester.pump();

    // Sheet stays open — create was not invoked
    verifyNever(() => _mockCreateNote(any()));
    expect(find.text('Create Note'), findsOneWidget);
  });

  // ── Delete note ───────────────────────────────────────────────────────────

  testWidgets('shows confirm dialog when delete icon is tapped', (tester) async {
    when(() => _mockGetNotes(any()))
        .thenAnswer((_) async => Right(_testNotes));

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();

    expect(find.text('Delete note'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('cancels delete when Cancel is tapped', (tester) async {
    when(() => _mockGetNotes(any()))
        .thenAnswer((_) async => Right(_testNotes));

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => _mockDeleteNote(any()));
  });

  testWidgets('deletes note after confirm', (tester) async {
    when(() => _mockGetNotes(any()))
        .thenAnswer((_) async => Right(_testNotes));
    when(() => _mockDeleteNote(any()))
        .thenAnswer((_) async => const Right('deleted'));

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    verify(() => _mockDeleteNote(const DeleteNoteParams(id: 1))).called(1);
  });

  // ── Edit note ─────────────────────────────────────────────────────────────

  testWidgets('opens Edit Note sheet when a note card is tapped', (tester) async {
    when(() => _mockGetNotes(any()))
        .thenAnswer((_) async => Right(_testNotes));

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    // Tap the InkWell of the first note card (not the delete button)
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    expect(find.text('Edit Note'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });

  // ── Logout ────────────────────────────────────────────────────────────────

  testWidgets('logout clears token and navigates to welcome', (tester) async {
    when(() => _mockGetNotes(any()))
        .thenAnswer((_) async => Right(_testNotes));
    when(() => _mockStorage.deleteToken()).thenAnswer((_) async {});

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.logout_rounded));
    await tester.pumpAndSettle();

    verify(() => _mockStorage.deleteToken()).called(1);
    expect(find.text('Welcome'), findsOneWidget);
  });
}
