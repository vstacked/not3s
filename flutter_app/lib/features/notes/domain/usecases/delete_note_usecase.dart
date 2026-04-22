import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:not3s/core/error/failures.dart';
import 'package:not3s/core/usecases/usecase.dart';
import 'package:not3s/features/notes/domain/repositories/notes_repository.dart';

class DeleteNoteUseCase extends UseCase<String, DeleteNoteParams> {
  final NotesRepository repository;

  DeleteNoteUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(DeleteNoteParams params) {
    return repository.deleteNote(params.id);
  }
}

class DeleteNoteParams extends Equatable {
  final int id;

  const DeleteNoteParams({required this.id});

  @override
  List<Object> get props => [id];
}
