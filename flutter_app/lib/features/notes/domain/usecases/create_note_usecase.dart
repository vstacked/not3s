import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:not3s/core/error/failures.dart';
import 'package:not3s/core/usecases/usecase.dart';
import 'package:not3s/features/notes/domain/repositories/notes_repository.dart';

class CreateNoteUseCase extends UseCase<String, CreateNoteParams> {
  final NotesRepository repository;

  CreateNoteUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(CreateNoteParams params) {
    return repository.createNote(params.title, params.content);
  }
}

class CreateNoteParams extends Equatable {
  final String title;
  final String content;

  const CreateNoteParams({required this.title, required this.content});

  @override
  List<Object> get props => [title, content];
}
