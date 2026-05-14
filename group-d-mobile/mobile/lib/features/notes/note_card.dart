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
          showModalBottomSheet<void>(
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
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ChipLabel(
                          label: note.moduleId == null
                              ? 'SANS MODULE'
                              : _moduleLabel(note.moduleId!),
                          color: _noteColor(note.color),
                        ),
                        for (final tag in note.tags.take(2))
                          _ChipLabel(
                            label: '#$tag',
                            color: MiraTheme.warmBeige,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      note.isFavorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 22,
                      color: note.isFavorite ? MiraTheme.gold : MiraTheme.muted,
                    ),
                    onPressed: () {
                      ref.read(notesProvider.notifier).toggleFavorite(note);
                    },
                    tooltip: 'Favori',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: MiraTheme.muted,
                    ),
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

  static String _moduleLabel(String value) {
    final prefix = value.length >= 4 ? value.substring(0, 4) : value;
    final suffix =
        value.length >= 4 ? value.substring(value.length - 4) : value;
    return 'MODULE $prefix-$suffix';
  }

  static Color _noteColor(String? color) {
    return switch (color) {
      'green' => MiraTheme.pastelSage,
      'yellow' => MiraTheme.beigeDeep,
      _ => MiraTheme.beigeDeep,
    };
  }
}

class _ChipLabel extends StatelessWidget {
  const _ChipLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: MiraTheme.charcoal,
        ),
      ),
    );
  }
}
