import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:not3s/core/error/failures.dart';
import 'package:not3s/core/usecases/usecase.dart';
import 'package:not3s/features/notes/domain/entities/note_entity.dart';
import 'package:not3s/features/notes/domain/usecases/create_note_usecase.dart';
import 'package:not3s/features/notes/domain/usecases/delete_note_usecase.dart';
import 'package:not3s/features/notes/domain/usecases/get_notes_usecase.dart';
import 'package:not3s/features/notes/domain/usecases/update_note_usecase.dart';

part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc({
    required this.getNotesUseCase,
    required this.createNoteUseCase,
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
  }) : super(const NotesInitial()) {
    on<NotesLoad>(_onLoad);
    on<NotesSearch>(_onSearch);
    on<NotesCreate>(_onCreate);
    on<NotesUpdate>(_onUpdate);
    on<NotesDelete>(_onDelete);
  }

  final GetNotesUseCase getNotesUseCase;
  final CreateNoteUseCase createNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;

  String _failureMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    return 'Network error. Please check your connection.';
  }

  Future<void> _onLoad(NotesLoad event, Emitter<NotesState> emit) async {
    emit(const NotesLoading());
    final result = await getNotesUseCase(const NoParams());
    result.fold(
      (failure) => emit(NotesFailure(message: _failureMessage(failure))),
      (notes) => emit(NotesLoaded(notes: notes)),
    );
  }

  void _onSearch(NotesSearch event, Emitter<NotesState> emit) {
    if (state is! NotesLoaded) return;
    final current = state as NotesLoaded;
    final query = event.query.toLowerCase().trim();
    if (query.isEmpty) {
      emit(current.copyWith(searchQuery: '', filteredNotes: []));
      return;
    }
    final filtered = current.notes.where((note) {
      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query);
    }).toList();
    emit(current.copyWith(searchQuery: query, filteredNotes: filtered));
  }

  Future<void> _onCreate(NotesCreate event, Emitter<NotesState> emit) async {
    final current = state;
    if (current is NotesLoaded) {
      emit(NotesActionLoading(notes: current.notes));
    }
    final result = await createNoteUseCase(
      CreateNoteParams(title: event.title, content: event.content),
    );
    result.fold(
      (failure) => emit(NotesFailure(message: _failureMessage(failure))),
      (_) => add(const NotesLoad()),
    );
  }

  Future<void> _onUpdate(NotesUpdate event, Emitter<NotesState> emit) async {
    final current = state;
    if (current is NotesLoaded) {
      emit(NotesActionLoading(notes: current.notes));
    }
    final result = await updateNoteUseCase(
      UpdateNoteParams(id: event.id, title: event.title, content: event.content),
    );
    result.fold(
      (failure) => emit(NotesFailure(message: _failureMessage(failure))),
      (_) => add(const NotesLoad()),
    );
  }

  Future<void> _onDelete(NotesDelete event, Emitter<NotesState> emit) async {
    final current = state;
    if (current is NotesLoaded) {
      emit(NotesActionLoading(notes: current.notes));
    }
    final result = await deleteNoteUseCase(DeleteNoteParams(id: event.id));
    result.fold(
      (failure) => emit(NotesFailure(message: _failureMessage(failure))),
      (_) => add(const NotesLoad()),
    );
  }
}
