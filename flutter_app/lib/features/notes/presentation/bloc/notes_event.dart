part of 'notes_bloc.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

class NotesLoad extends NotesEvent {
  const NotesLoad();
}

class NotesSearch extends NotesEvent {
  const NotesSearch({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

class NotesCreate extends NotesEvent {
  const NotesCreate({required this.title, required this.content});

  final String title;
  final String content;

  @override
  List<Object?> get props => [title, content];
}

class NotesUpdate extends NotesEvent {
  const NotesUpdate({
    required this.id,
    required this.title,
    required this.content,
  });

  final int id;
  final String title;
  final String content;

  @override
  List<Object?> get props => [id, title, content];
}

class NotesDelete extends NotesEvent {
  const NotesDelete({required this.id});

  final int id;

  @override
  List<Object?> get props => [id];
}
