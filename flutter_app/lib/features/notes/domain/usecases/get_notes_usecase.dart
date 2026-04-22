import 'package:dartz/dartz.dart';
import 'package:not3s/core/error/failures.dart';
import 'package:not3s/core/usecases/usecase.dart';
import 'package:not3s/features/notes/domain/entities/note_entity.dart';
import 'package:not3s/features/notes/domain/repositories/notes_repository.dart';

class GetNotesUseCase extends UseCase<List<NoteEntity>, NoParams> {
  final NotesRepository repository;

  GetNotesUseCase(this.repository);

  @override
  Future<Either<Failure, List<NoteEntity>>> call(NoParams params) {
    return repository.getNotes();
  }
}
