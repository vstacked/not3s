import 'package:flutter/material.dart';
import 'package:not3s/core/utils/date_formatter.dart';
import 'package:not3s/features/notes/domain/entities/note_entity.dart';
import '../styles/app_colors.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  final NoteEntity note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NoteTitle(title: note.title),
                    if (note.content.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _NotePreview(content: note.content),
                    ],
                    const SizedBox(height: 8),
                    _NoteTimestamp(updatedAt: note.updatedAt),
                  ],
                ),
              ),
              _DeleteButton(onDelete: onDelete),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteTitle extends StatelessWidget {
  const _NoteTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _NotePreview extends StatelessWidget {
  const _NotePreview({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _NoteTimestamp extends StatelessWidget {
  const _NoteTimestamp({required this.updatedAt});

  final DateTime updatedAt;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.access_time, size: 11, color: AppColors.textHint),
        const SizedBox(width: 4),
        Text(
          formatRelativeTime(updatedAt),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textHint,
                fontSize: 11,
              ),
        ),
      ],
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onDelete});

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textHint),
      onPressed: onDelete,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      tooltip: 'Delete note',
    );
  }
}
