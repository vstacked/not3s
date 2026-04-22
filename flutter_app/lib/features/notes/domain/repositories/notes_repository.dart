import 'package:dartz/dartz.dart';
import 'package:not3s/core/error/failures.dart';
import 'package:not3s/features/notes/domain/entities/note_entity.dart';

abstract class NotesRepository {
  Future<Either<Failure, List<NoteEntity>>> getNotes();
  Future<Either<Failure, String>> createNote(String title, String content);
  Future<Either<Failure, String>> updateNote(
    int id,
    String title,
    String content,
  );
  Future<Either<Failure, String>> deleteNote(int id);
}
