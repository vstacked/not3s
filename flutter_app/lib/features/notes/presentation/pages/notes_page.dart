import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:not3s/core/router/router.dart';
import 'package:not3s/core/storage/storage_service.dart';
import 'package:not3s/core/styles/app_colors.dart';
import 'package:not3s/core/utils/injections.dart';
import 'package:not3s/core/widgets/app_button.dart';
import 'package:not3s/core/widgets/app_confirm_dialog.dart';
import 'package:not3s/core/widgets/app_search_bar.dart';
import 'package:not3s/core/widgets/app_text_field.dart';
import 'package:not3s/core/widgets/empty_state.dart';
import 'package:not3s/core/widgets/note_card.dart';
import 'package:not3s/features/notes/domain/entities/note_entity.dart';
import 'package:not3s/features/notes/presentation/bloc/notes_bloc.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotesBloc>()..add(const NotesLoad()),
      child: const _NotesView(),
    );
  }
}

class _NotesView extends StatefulWidget {
  const _NotesView();

  @override
  State<_NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<_NotesView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await sl<StorageService>().deleteToken();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.welcome,
        (_) => false,
      );
    }
  }

  void _showNoteSheet({NoteEntity? note}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<NotesBloc>(),
        child: _NoteSheet(existing: note),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _NotesAppBar(onLogout: _logout),
      body: BlocConsumer<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NotesFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final notes = switch (state) {
            NotesLoaded() => state.displayNotes,
            NotesActionLoading() => state.notes,
            _ => const <NoteEntity>[],
          };

          final isActionLoading = state is NotesActionLoading;

          return Column(
            children: [
              _SearchSection(
                controller: _searchController,
                onChanged: (query) =>
                    context.read<NotesBloc>().add(NotesSearch(query: query)),
              ),
              Expanded(
                child: notes.isEmpty && state is NotesLoaded
                    ? _searchController.text.isNotEmpty
                        ? const EmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'No results found',
                            subtitle: 'Try a different keyword',
                          )
                        : const EmptyState(
                            icon: Icons.note_alt_outlined,
                            title: 'No notes yet',
                            subtitle: 'Tap + to create your first note',
                          )
                    : _NotesList(
                        notes: notes,
                        isLoading: isActionLoading,
                        onTap: (note) => _showNoteSheet(note: note),
                        onDelete: (note) async {
                          final confirmed = await showAppConfirmDialog(
                            context,
                            title: 'Delete note',
                            message:
                                'Are you sure you want to delete "${note.title}"?',
                          );
                          if (confirmed && context.mounted) {
                            context
                                .read<NotesBloc>()
                                .add(NotesDelete(id: note.id));
                          }
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteSheet(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ─── App Bar ────────────────────────────────────────────────────────────────

class _NotesAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _NotesAppBar({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(
        'not3s',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded,
              color: AppColors.onSurfaceVariant),
          onPressed: onLogout,
          tooltip: 'Logout',
        ),
      ],
    );
  }
}

// ─── Search Section ─────────────────────────────────────────────────────────

class _SearchSection extends StatelessWidget {
  const _SearchSection({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: AppSearchBar(controller: controller, onChanged: onChanged),
    );
  }
}

// ─── Notes List ─────────────────────────────────────────────────────────────

class _NotesList extends StatelessWidget {
  const _NotesList({
    required this.notes,
    required this.isLoading,
    required this.onTap,
    required this.onDelete,
  });

  final List<NoteEntity> notes;
  final bool isLoading;
  final ValueChanged<NoteEntity> onTap;
  final ValueChanged<NoteEntity> onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          itemCount: notes.length,
          itemBuilder: (_, i) => NoteCard(
            note: notes[i],
            onTap: () => onTap(notes[i]),
            onDelete: () => onDelete(notes[i]),
          ),
        ),
        if (isLoading)
          const Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              color: AppColors.primary,
              minHeight: 2,
            ),
          ),
      ],
    );
  }
}

// ─── Note Sheet (Create / Edit) ─────────────────────────────────────────────

class _NoteSheet extends StatefulWidget {
  const _NoteSheet({this.existing});

  final NoteEntity? existing;

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existing?.title ?? '');
    _contentController =
        TextEditingController(text: widget.existing?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    if (_isEditing) {
      context.read<NotesBloc>().add(NotesUpdate(
            id: widget.existing!.id,
            title: title,
            content: content,
          ));
    } else {
      context
          .read<NotesBloc>()
          .add(NotesCreate(title: title, content: content));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHeader(isEditing: _isEditing),
          const SizedBox(height: 20),
          AppTextField(
            controller: _titleController,
            hintText: 'Title',
            textInputAction: TextInputAction.next,
            autofocus: true,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _contentController,
            hintText: 'Content',
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: _isEditing ? 'Save Changes' : 'Create Note',
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isEditing ? 'Edit Note' : 'New Note',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.textHint),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
