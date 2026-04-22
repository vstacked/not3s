import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:not3s/core/error/failures.dart';
import 'package:not3s/core/usecases/usecase.dart';
import 'package:not3s/features/notes/domain/repositories/notes_repository.dart';

class UpdateNoteUseCase extends UseCase<String, UpdateNoteParams> {
  final NotesRepository repository;

  UpdateNoteUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(UpdateNoteParams params) {
    return repository.updateNote(params.id, params.title, params.content);
  }
}

class UpdateNoteParams extends Equatable {
  final int id;
  final String title;
  final String content;

  const UpdateNoteParams({
    required this.id,
    required this.title,
    required this.content,
  });

  @override
  List<Object> get props => [id, title, content];
}
