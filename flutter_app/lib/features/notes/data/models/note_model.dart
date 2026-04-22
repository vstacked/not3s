import 'package:not3s/features/notes/domain/entities/note_entity.dart';

class NoteModel extends NoteEntity {
  const NoteModel({
    required super.id,
    required super.title,
    required super.content,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
      };
}
