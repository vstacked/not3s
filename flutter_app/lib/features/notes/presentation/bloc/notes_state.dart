part of 'notes_bloc.dart';

abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

class NotesInitial extends NotesState {
  const NotesInitial();
}

class NotesLoading extends NotesState {
  const NotesLoading();
}

class NotesLoaded extends NotesState {
  const NotesLoaded({
    required this.notes,
    this.filteredNotes,
    this.searchQuery = '',
  });

  final List<NoteEntity> notes;
  final List<NoteEntity>? filteredNotes;
  final String searchQuery;

  List<NoteEntity> get displayNotes =>
      searchQuery.isEmpty ? notes : (filteredNotes ?? notes);

  NotesLoaded copyWith({
    List<NoteEntity>? notes,
    List<NoteEntity>? filteredNotes,
    String? searchQuery,
  }) {
    return NotesLoaded(
      notes: notes ?? this.notes,
      filteredNotes: filteredNotes ?? this.filteredNotes,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [notes, filteredNotes, searchQuery];
}

class NotesActionLoading extends NotesState {
  const NotesActionLoading({required this.notes});

  final List<NoteEntity> notes;

  @override
  List<Object?> get props => [notes];
}

class NotesFailure extends NotesState {
  const NotesFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
