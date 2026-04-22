import 'package:dio/dio.dart';
import 'package:not3s/core/error/exceptions.dart';
import 'package:not3s/core/network/dio_network.dart';
import 'package:not3s/features/notes/data/models/note_model.dart';

abstract class NotesRemoteDataSource {
  Future<List<NoteModel>> getNotes();
  Future<String> createNote(String title, String content);
  Future<String> updateNote(int id, String title, String content);
  Future<String> deleteNote(int id);
}

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  final Dio dio;

  NotesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<NoteModel>> getNotes() async {
    try {
      final response = await dio.get('/notes');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => NoteModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final message =
          (e.response?.data as Map<String, dynamic>?)?['error'] as String? ??
              'Failed to fetch notes';
      throw ServerException(message: message);
    }
  }

  @override
  Future<String> createNote(String title, String content) async {
    try {
      final response = await dio.post(
        '/notes',
        data: {'title': title, 'content': content},
      );
      return (response.data as Map<String, dynamic>)['message'] as String;
    } on DioException catch (e) {
      final message =
          (e.response?.data as Map<String, dynamic>?)?['error'] as String? ??
              'Failed to create note';
      throw ServerException(message: message);
    }
  }

  @override
  Future<String> updateNote(int id, String title, String content) async {
    try {
      final response = await dio.put(
        '/notes/$id',
        data: {'title': title, 'content': content},
      );
      return (response.data as Map<String, dynamic>)['message'] as String;
    } on DioException catch (e) {
      final message =
          (e.response?.data as Map<String, dynamic>?)?['error'] as String? ??
              'Failed to update note';
      throw ServerException(message: message);
    }
  }

  @override
  Future<String> deleteNote(int id) async {
    try {
      final response = await dio.delete('/notes/$id');
      return (response.data as Map<String, dynamic>)['message'] as String;
    } on DioException catch (e) {
      final message =
          (e.response?.data as Map<String, dynamic>?)?['error'] as String? ??
              'Failed to delete note';
      throw ServerException(message: message);
    }
  }
}
