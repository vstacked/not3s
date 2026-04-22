import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:not3s/core/error/failures.dart';
import 'package:not3s/core/usecases/usecase.dart';
import 'package:not3s/features/notes/domain/entities/note_entity.dart';
import 'package:not3s/features/notes/domain/usecases/create_note_usecase.dart';
import 'package:not3s/features/notes/domain/usecases/delete_note_usecase.dart';
import 'package:not3s/features/notes/domain/usecases/get_notes_usecase.dart';
import 'package:not3s/features/notes/domain/usecases/update_note_usecase.dart';
import 'package:not3s/features/notes/presentation/bloc/notes_bloc.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockGetNotesUseCase extends Mock implements GetNotesUseCase {}

class MockCreateNoteUseCase extends Mock implements CreateNoteUseCase {}

class MockUpdateNoteUseCase extends Mock implements UpdateNoteUseCase {}

class MockDeleteNoteUseCase extends Mock implements DeleteNoteUseCase {}

// ── Helpers ───────────────────────────────────────────────────────────────────

final _note1 = NoteEntity(
  id: 1,
  title: 'First Note',
  content: 'Content one',
  updatedAt: DateTime.utc(2024, 4, 1),
);
final _note2 = NoteEntity(
  id: 2,
  title: 'Second Note',
  content: 'Content two',
  updatedAt: DateTime.utc(2024, 4, 2),
);
final _testNotes = [_note1, _note2];

void main() {
  late MockGetNotesUseCase mockGetNotes;
  late MockCreateNoteUseCase mockCreateNote;
  late MockUpdateNoteUseCase mockUpdateNote;
  late MockDeleteNoteUseCase mockDeleteNote;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const CreateNoteParams(title: '', content: ''));
    registerFallbackValue(const DeleteNoteParams(id: 0));
    registerFallbackValue(const UpdateNoteParams(id: 0, title: '', content: ''));
  });

  setUp(() {
    mockGetNotes = MockGetNotesUseCase();
    mockCreateNote = MockCreateNoteUseCase();
    mockUpdateNote = MockUpdateNoteUseCase();
    mockDeleteNote = MockDeleteNoteUseCase();
  });

  NotesBloc _buildBloc() => NotesBloc(
        getNotesUseCase: mockGetNotes,
        createNoteUseCase: mockCreateNote,
        updateNoteUseCase: mockUpdateNote,
        deleteNoteUseCase: mockDeleteNote,
      );

  // ── Initial state ─────────────────────────────────────────────────────────

  test('initial state is NotesInitial', () {
    expect(_buildBloc().state, const NotesInitial());
  });

  // ── NotesLoad ─────────────────────────────────────────────────────────────

  group('NotesLoad', () {
    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesLoaded] on success',
      build: () {
        when(() => mockGetNotes(any()))
            .thenAnswer((_) async => Right(_testNotes));
        return _buildBloc();
      },
      act: (bloc) => bloc.add(const NotesLoad()),
      expect: () => [
        const NotesLoading(),
        NotesLoaded(notes: _testNotes),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesLoaded(empty)] when no notes exist',
      build: () {
        when(() => mockGetNotes(any()))
            .thenAnswer((_) async => const Right([]));
        return _buildBloc();
      },
      act: (bloc) => bloc.add(const NotesLoad()),
      expect: () => [
        const NotesLoading(),
        const NotesLoaded(notes: []),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesFailure] on ServerFailure',
      build: () {
        when(() => mockGetNotes(any())).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'Database unavailable')),
        );
        return _buildBloc();
      },
      act: (bloc) => bloc.add(const NotesLoad()),
      expect: () => [
        const NotesLoading(),
        const NotesFailure(message: 'Database unavailable'),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'emits generic network message on NetworkFailure',
      build: () {
        when(() => mockGetNotes(any()))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return _buildBloc();
      },
      act: (bloc) => bloc.add(const NotesLoad()),
      expect: () => [
        const NotesLoading(),
        const NotesFailure(
            message: 'Network error. Please check your connection.'),
      ],
    );
  });

  // ── NotesSearch ───────────────────────────────────────────────────────────

  group('NotesSearch', () {
    blocTest<NotesBloc, NotesState>(
      'filters notes by title (case-insensitive)',
      build: _buildBloc,
      seed: () => NotesLoaded(notes: _testNotes),
      act: (bloc) => bloc.add(const NotesSearch(query: 'FIRST')),
      expect: () => [
        NotesLoaded(
          notes: _testNotes,
          filteredNotes: [_note1],
          searchQuery: 'first',
        ),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'filters notes by content',
      build: _buildBloc,
      seed: () => NotesLoaded(notes: _testNotes),
      act: (bloc) => bloc.add(const NotesSearch(query: 'content two')),
      expect: () => [
        NotesLoaded(
          notes: _testNotes,
          filteredNotes: [_note2],
          searchQuery: 'content two',
        ),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'returns empty filteredNotes list when no match',
      build: _buildBloc,
      seed: () => NotesLoaded(notes: _testNotes),
      act: (bloc) => bloc.add(const NotesSearch(query: 'xyz-no-match')),
      expect: () => [
        NotesLoaded(
          notes: _testNotes,
          filteredNotes: [],
          searchQuery: 'xyz-no-match',
        ),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'clears filter when query is empty',
      build: _buildBloc,
      seed: () => NotesLoaded(
        notes: _testNotes,
        filteredNotes: [_note1],
        searchQuery: 'first',
      ),
      act: (bloc) => bloc.add(const NotesSearch(query: '')),
      expect: () => [
        NotesLoaded(notes: _testNotes, filteredNotes: [], searchQuery: ''),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'ignores leading/trailing whitespace in query',
      build: _buildBloc,
      seed: () => NotesLoaded(notes: _testNotes),
      act: (bloc) => bloc.add(const NotesSearch(query: '  first  ')),
      expect: () => [
        NotesLoaded(
          notes: _testNotes,
          filteredNotes: [_note1],
          searchQuery: 'first',
        ),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'does nothing when state is not NotesLoaded',
      build: _buildBloc,
      seed: () => const NotesInitial(),
      act: (bloc) => bloc.add(const NotesSearch(query: 'anything')),
      expect: () => [],
    );

    blocTest<NotesBloc, NotesState>(
      'returns all notes when query matches all',
      build: _buildBloc,
      seed: () => NotesLoaded(notes: _testNotes),
      act: (bloc) => bloc.add(const NotesSearch(query: 'content')),
      expect: () => [
        NotesLoaded(
          notes: _testNotes,
          filteredNotes: _testNotes,
          searchQuery: 'content',
        ),
      ],
    );
  });

  // ── NotesCreate ───────────────────────────────────────────────────────────

  group('NotesCreate', () {
    blocTest<NotesBloc, NotesState>(
      'emits [ActionLoading, Loading, Loaded] on success',
      build: () {
        when(() => mockCreateNote(any()))
            .thenAnswer((_) async => const Right('created'));
        when(() => mockGetNotes(any()))
            .thenAnswer((_) async => Right(_testNotes));
        return _buildBloc();
      },
      seed: () => NotesLoaded(notes: _testNotes),
      act: (bloc) =>
          bloc.add(const NotesCreate(title: 'New', content: 'Body')),
      expect: () => [
        NotesActionLoading(notes: _testNotes),
        const NotesLoading(),
        NotesLoaded(notes: _testNotes),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'emits [ActionLoading, NotesFailure] when create fails',
      build: () {
        when(() => mockCreateNote(any())).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'Failed to create note')),
        );
        return _buildBloc();
      },
      seed: () => NotesLoaded(notes: _testNotes),
      act: (bloc) =>
          bloc.add(const NotesCreate(title: 'New', content: 'Body')),
      expect: () => [
        NotesActionLoading(notes: _testNotes),
        const NotesFailure(message: 'Failed to create note'),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'passes correct params to use case',
      build: () {
        when(() => mockCreateNote(any()))
            .thenAnswer((_) async => const Right('ok'));
        when(() => mockGetNotes(any()))
            .thenAnswer((_) async => const Right([]));
        return _buildBloc();
      },
      seed: () => NotesLoaded(notes: _testNotes),
      act: (bloc) => bloc.add(
          const NotesCreate(title: 'Exact Title', content: 'Exact Content')),
      verify: (_) {
        verify(() => mockCreateNote(const CreateNoteParams(
              title: 'Exact Title',
              content: 'Exact Content',
            ))).called(1);
      },
    );
  });

  // ── NotesUpdate ───────────────────────────────────────────────────────────

  group('NotesUpdate', () {
    blocTest<NotesBloc, NotesState>(
      'emits [ActionLoading, Loading, Loaded] on success',
      build: () {
        when(() => mockUpdateNote(any()))
            .thenAnswer((_) async => const Right('updated'));
        when(() => mockGetNotes(any()))
            .thenAnswer((_) async => Right(_testNotes));
        return _buildBloc();
      },
      seed: () => NotesLoaded(notes: _testNotes),
      act: (bloc) =>
          bloc.add(const NotesUpdate(id: 1, title: 'Updated', content: 'New')),
      expect: () => [
        NotesActionLoading(notes: _testNotes),
        const NotesLoading(),
        NotesLoaded(notes: _testNotes),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'emits [ActionLoading, NotesFailure] when update fails',
      build: () {
        when(() => mockUpdateNote(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Note not found')),
        );
        return _buildBloc();
      },
      seed: () => NotesLoaded(notes: _testNotes),
      act: (bloc) =>
          bloc.add(const NotesUpdate(id: 99, title: 'X', content: 'Y')),
      expect: () => [
        NotesActionLoading(notes: _testNotes),
        const NotesFailure(message: 'Note not found'),
      ],
    );
  });

  // ── NotesDelete ───────────────────────────────────────────────────────────

  group('NotesDelete', () {
    blocTest<NotesBloc, NotesState>(
      'emits [ActionLoading, Loading, Loaded(empty)] on success',
      build: () {
        when(() => mockDeleteNote(any()))
            .thenAnswer((_) async => const Right('deleted'));
        when(() => mockGetNotes(any()))
            .thenAnswer((_) async => const Right([]));
        return _buildBloc();
      },
      seed: () => NotesLoaded(notes: _testNotes),
      act: (bloc) => bloc.add(const NotesDelete(id: 1)),
      expect: () => [
        NotesActionLoading(notes: _testNotes),
        const NotesLoading(),
        const NotesLoaded(notes: []),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'emits [ActionLoading, NotesFailure] when delete fails',
      build: () {
        when(() => mockDeleteNote(any())).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'Delete failed')),
        );
        return _buildBloc();
      },
      seed: () => NotesLoaded(notes: _testNotes),
      act: (bloc) => bloc.add(const NotesDelete(id: 1)),
      expect: () => [
        NotesActionLoading(notes: _testNotes),
        const NotesFailure(message: 'Delete failed'),
      ],
    );

    blocTest<NotesBloc, NotesState>(
      'passes correct id to delete use case',
      build: () {
        when(() => mockDeleteNote(any()))
            .thenAnswer((_) async => const Right('ok'));
        when(() => mockGetNotes(any()))
            .thenAnswer((_) async => const Right([]));
        return _buildBloc();
      },
      seed: () => NotesLoaded(notes: _testNotes),
      act: (bloc) => bloc.add(const NotesDelete(id: 42)),
      verify: (_) {
        verify(() => mockDeleteNote(const DeleteNoteParams(id: 42))).called(1);
      },
    );
  });

  // ── NotesLoaded.displayNotes ──────────────────────────────────────────────

  group('NotesLoaded.displayNotes', () {
    test('returns notes when searchQuery is empty', () {
      final state = NotesLoaded(notes: _testNotes);
      expect(state.displayNotes, _testNotes);
    });

    test('returns filteredNotes when searchQuery is non-empty', () {
      final state = NotesLoaded(
        notes: _testNotes,
        filteredNotes: [_note1],
        searchQuery: 'first',
      );
      expect(state.displayNotes, [_note1]);
    });

    test('falls back to notes when filteredNotes is null but query is set', () {
      final state = NotesLoaded(
        notes: _testNotes,
        filteredNotes: null,
        searchQuery: 'something',
      );
      expect(state.displayNotes, _testNotes);
    });
  });
}
