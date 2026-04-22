import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:not3s/core/widgets/note_card.dart';
import 'package:not3s/features/notes/domain/entities/note_entity.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _buildCard({
  required NoteEntity note,
  VoidCallback? onTap,
  VoidCallback? onDelete,
}) {
  return MaterialApp(
    home: Scaffold(
      body: NoteCard(
        note: note,
        onTap: onTap ?? () {},
        onDelete: onDelete ?? () {},
      ),
    ),
  );
}

final _note = NoteEntity(
  id: 1,
  title: 'My Test Note',
  content: 'This is the note content.',
  updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('NoteCard rendering', () {
    testWidgets('displays the note title', (tester) async {
      await tester.pumpWidget(_buildCard(note: _note));
      expect(find.text('My Test Note'), findsOneWidget);
    });

    testWidgets('displays content preview', (tester) async {
      await tester.pumpWidget(_buildCard(note: _note));
      expect(find.text('This is the note content.'), findsOneWidget);
    });

    testWidgets('displays a relative timestamp', (tester) async {
      await tester.pumpWidget(_buildCard(note: _note));
      expect(find.text('5 min ago'), findsOneWidget);
    });

    testWidgets('shows delete icon button', (tester) async {
      await tester.pumpWidget(_buildCard(note: _note));
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('shows clock icon next to timestamp', (tester) async {
      await tester.pumpWidget(_buildCard(note: _note));
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });
  });

  group('NoteCard callbacks', () {
    testWidgets('calls onTap when the card body is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_buildCard(note: _note, onTap: () => tapped = true));
      await tester.tap(find.byType(InkWell).first);
      expect(tapped, isTrue);
    });

    testWidgets('calls onDelete when delete button is pressed', (tester) async {
      var deleted = false;
      await tester.pumpWidget(
          _buildCard(note: _note, onDelete: () => deleted = true));
      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(deleted, isTrue);
    });

    testWidgets('onTap and onDelete are independent', (tester) async {
      var tapCount = 0;
      var deleteCount = 0;
      await tester.pumpWidget(_buildCard(
        note: _note,
        onTap: () => tapCount++,
        onDelete: () => deleteCount++,
      ));

      await tester.tap(find.byType(InkWell).first);
      await tester.tap(find.byIcon(Icons.delete_outline));

      expect(tapCount, 1);
      expect(deleteCount, 1);
    });
  });

  group('NoteCard edge cases', () {
    testWidgets('does NOT render preview section when content is empty',
        (tester) async {
      final emptyContent = NoteEntity(
        id: 2,
        title: 'Title Only',
        content: '',
        updatedAt: DateTime.now(),
      );
      await tester.pumpWidget(_buildCard(note: emptyContent));

      expect(find.text('Title Only'), findsOneWidget);
      // No content Text widget should be present
      expect(find.text(''), findsNothing);
    });

    testWidgets('handles very long title with ellipsis overflow',
        (tester) async {
      final longTitle = NoteEntity(
        id: 3,
        title: 'A' * 200,
        content: 'Short content',
        updatedAt: DateTime.now(),
      );
      await tester.pumpWidget(_buildCard(note: longTitle));

      final text = tester.widget<Text>(find.text('A' * 200));
      expect(text.overflow, TextOverflow.ellipsis);
      expect(text.maxLines, 1);
    });

    testWidgets('content preview is capped at 2 lines', (tester) async {
      final multiLineContent = NoteEntity(
        id: 4,
        title: 'Title',
        content: 'Line 1\nLine 2\nLine 3\nLine 4',
        updatedAt: DateTime.now(),
      );
      await tester.pumpWidget(_buildCard(note: multiLineContent));

      final contentText = tester.widgetList<Text>(find.byType(Text)).firstWhere(
            (t) => t.data?.contains('Line') ?? false,
          );
      expect(contentText.maxLines, 2);
    });

    testWidgets('renders note with unicode title and content', (tester) async {
      final unicodeNote = NoteEntity(
        id: 5,
        title: '日本語 🎉',
        content: 'Ünïcödé çøntent',
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      );
      await tester.pumpWidget(_buildCard(note: unicodeNote));

      expect(find.text('日本語 🎉'), findsOneWidget);
      expect(find.text('Ünïcödé çøntent'), findsOneWidget);
    });

    testWidgets('shows "just now" for a note created seconds ago',
        (tester) async {
      final freshNote = NoteEntity(
        id: 6,
        title: 'Fresh',
        content: 'Just created',
        updatedAt: DateTime.now(),
      );
      await tester.pumpWidget(_buildCard(note: freshNote));
      expect(find.text('just now'), findsOneWidget);
    });

    testWidgets('delete button has minimum touch target', (tester) async {
      await tester.pumpWidget(_buildCard(note: _note));
      final iconBtn = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconBtn.constraints?.minWidth, 32);
      expect(iconBtn.constraints?.minHeight, 32);
    });
  });
}
