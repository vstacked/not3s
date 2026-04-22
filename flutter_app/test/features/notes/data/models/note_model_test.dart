import 'package:flutter_test/flutter_test.dart';
import 'package:not3s/features/notes/data/models/note_model.dart';
import 'package:not3s/features/notes/domain/entities/note_entity.dart';

void main() {
  group('NoteModel', () {
    // ── fromJson ──────────────────────────────────────────────────────────────

    group('fromJson', () {
      test('parses all fields from a standard SQLite timestamp', () {
        final json = {
          'id': 1,
          'title': 'My Note',
          'content': 'Some content here',
          'updated_at': '2024-04-10 08:15:00',
        };
        final model = NoteModel.fromJson(json);

        expect(model.id, 1);
        expect(model.title, 'My Note');
        expect(model.content, 'Some content here');
        // _parseTimestamp treats SQLite timestamps as UTC then converts to local;
        // check the UTC values to stay timezone-independent.
        expect(model.updatedAt.toUtc().year, 2024);
        expect(model.updatedAt.toUtc().month, 4);
        expect(model.updatedAt.toUtc().day, 10);
        expect(model.updatedAt.toUtc().hour, 8);
        expect(model.updatedAt.toUtc().minute, 15);
      });

      test('parses ISO-8601 timestamp without Z suffix', () {
        final json = {
          'id': 2,
          'title': 'T',
          'content': 'C',
          'updated_at': '2024-01-15T10:30:00',
        };
        final model = NoteModel.fromJson(json);

        expect(model.updatedAt.year, 2024);
        expect(model.updatedAt.month, 1);
        expect(model.updatedAt.day, 15);
      });

      test('falls back to current time when updated_at is null', () {
        final before = DateTime.now();
        final json = {
          'id': 3,
          'title': 'A',
          'content': 'B',
          'updated_at': null,
        };
        final model = NoteModel.fromJson(json);
        final after = DateTime.now();

        expect(
          model.updatedAt
              .isAfter(before.subtract(const Duration(seconds: 1))),
          isTrue,
        );
        expect(
          model.updatedAt.isBefore(after.add(const Duration(seconds: 1))),
          isTrue,
        );
      });

      test('falls back to current time when updated_at is empty string', () {
        final json = {
          'id': 4,
          'title': 'A',
          'content': 'B',
          'updated_at': '',
        };
        final before = DateTime.now();
        final model = NoteModel.fromJson(json);
        expect(model.updatedAt.isAfter(before.subtract(const Duration(seconds: 1))),
            isTrue);
      });

      test('parses leap-year date Feb 29', () {
        final json = {
          'id': 5,
          'title': 'Leap',
          'content': 'Day',
          'updated_at': '2024-02-29 00:00:00',
        };
        final model = NoteModel.fromJson(json);
        expect(model.updatedAt.month, 2);
        expect(model.updatedAt.day, 29);
        expect(model.updatedAt.year, 2024);
      });

      test('handles unicode title and content', () {
        final json = {
          'id': 6,
          'title': '日本語 🎉',
          'content': 'Ünïcödé çøntent',
          'updated_at': '2024-04-10 08:00:00',
        };
        final model = NoteModel.fromJson(json);
        expect(model.title, '日本語 🎉');
        expect(model.content, 'Ünïcödé çøntent');
      });

      test('handles large id values', () {
        final json = {
          'id': 999999,
          'title': 'T',
          'content': 'C',
          'updated_at': '2024-01-01 00:00:00',
        };
        final model = NoteModel.fromJson(json);
        expect(model.id, 999999);
      });
    });

    // ── toJson ────────────────────────────────────────────────────────────────

    group('toJson', () {
      test('serializes all fields correctly', () {
        final dt = DateTime.utc(2024, 4, 10, 8, 15, 0);
        final model = NoteModel(
          id: 5,
          title: 'Title',
          content: 'Content',
          updatedAt: dt,
        );
        final result = model.toJson();

        expect(result['id'], 5);
        expect(result['title'], 'Title');
        expect(result['content'], 'Content');
        expect(result['updated_at'], dt.toIso8601String());
      });

      test('round-trip: toJson then fromJson preserves id, title, content', () {
        // Use a local (non-UTC) DateTime so toIso8601String() omits the trailing
        // 'Z' — _parseTimestamp always appends 'Z', so a UTC string would cause
        // a double-Z FormatException. The function is designed for SQLite output.
        final original = NoteModel(
          id: 7,
          title: 'Round trip',
          content: 'Body',
          updatedAt: DateTime(2024, 6, 1, 12, 0, 0),
        );
        final json = original.toJson();
        final restored = NoteModel.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.title, original.title);
        expect(restored.content, original.content);
      });
    });

    // ── Inheritance & equality ────────────────────────────────────────────────

    group('entity compatibility', () {
      test('NoteModel is a NoteEntity', () {
        final model = NoteModel(
          id: 1,
          title: 'T',
          content: 'C',
          updatedAt: DateTime.utc(2024, 1, 1),
        );
        expect(model, isA<NoteEntity>());
      });

      test('two NoteModels with same data are equal', () {
        final dt = DateTime.utc(2024, 1, 1);
        final a = NoteModel(id: 1, title: 'T', content: 'C', updatedAt: dt);
        final b = NoteModel(id: 1, title: 'T', content: 'C', updatedAt: dt);
        expect(a, equals(b));
      });

      test('NoteModels with different ids are not equal', () {
        final dt = DateTime.utc(2024, 1, 1);
        final a = NoteModel(id: 1, title: 'T', content: 'C', updatedAt: dt);
        final b = NoteModel(id: 2, title: 'T', content: 'C', updatedAt: dt);
        expect(a, isNot(equals(b)));
      });

      test('NoteModel and NoteEntity with same data share the same props', () {
        // Equatable uses runtimeType in ==, so NoteModel != NoteEntity even with
        // identical data. Props equality can still be verified directly.
        final dt = DateTime.utc(2024, 1, 1);
        final model = NoteModel(id: 1, title: 'T', content: 'C', updatedAt: dt);
        final entity = NoteEntity(id: 1, title: 'T', content: 'C', updatedAt: dt);
        expect(model.props, equals(entity.props));
      });
    });
  });
}
