import 'package:equatable/equatable.dart';

class NoteEntity extends Equatable {
  final int id;
  final String title;
  final String content;
  final DateTime updatedAt;

  const NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  @override
  List<Object> get props => [id, title, content, updatedAt];
}
