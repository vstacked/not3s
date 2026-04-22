import 'package:not3s/features/notes/domain/entities/note_entity.dart';

class NoteModel extends NoteEntity {
  const NoteModel({
    required super.id,
    required super.title,
    required super.content,
    required super.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      updatedAt: _parseTimestamp(json['updated_at'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'updated_at': updatedAt.toIso8601String(),
      };

  /// SQLite `CURRENT_TIMESTAMP` format is `"YYYY-MM-DD HH:MM:SS"` (UTC).
  /// We normalise it to ISO-8601 so `DateTime.parse` handles it correctly.
  static DateTime _parseTimestamp(String? raw) {
    if (raw == null || raw.isEmpty) return DateTime.now().toUtc();
    final normalised = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
    return DateTime.parse('${normalised}Z').toLocal();
  }
}
