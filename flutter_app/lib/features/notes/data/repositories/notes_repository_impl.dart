import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:not3s/core/error/exceptions.dart';
import 'package:not3s/core/error/failures.dart';
import 'package:not3s/features/notes/data/datasources/notes_remote_data_source.dart';
import 'package:not3s/features/notes/domain/entities/note_entity.dart';
import 'package:not3s/features/notes/domain/repositories/notes_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesRemoteDataSource remoteDataSource;

  NotesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<NoteEntity>>> getNotes() async {
    try {
      final notes = await remoteDataSource.getNotes();
      return Right(notes);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on DioException {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> createNote(
    String title,
    String content,
  ) async {
    try {
      final message = await remoteDataSource.createNote(title, content);
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on DioException {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> updateNote(
    int id,
    String title,
    String content,
  ) async {
    try {
      final message = await remoteDataSource.updateNote(id, title, content);
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on DioException {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> deleteNote(int id) async {
    try {
      final message = await remoteDataSource.deleteNote(id);
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on DioException {
      return Left(const NetworkFailure());
    }
  }
}
