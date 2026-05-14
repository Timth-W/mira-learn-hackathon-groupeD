import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'note_model.dart';
import 'notes_provider.dart';
import 'note_editor.dart';
import '../../core/theme/app_theme.dart';

class NoteCard extends ConsumerWidget {
  final Note note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: MiraTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MiraTheme.rule),
      ),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => NoteEditor(note: note),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: MiraTheme.warmBeige,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      note.moduleId == null ? 'SANS MODULE' : 'MODULE ${note.moduleId}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: MiraTheme.muted,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: MiraTheme.muted),
                    onPressed: () {
                      ref.read(notesProvider.notifier).deleteNote(note.id);
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                note.content,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: MiraTheme.charcoal,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Modifier',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: MiraTheme.miraRed,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.edit_outlined, size: 14, color: MiraTheme.miraRed),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
