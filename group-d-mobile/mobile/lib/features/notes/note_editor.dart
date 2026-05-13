import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'note_model.dart';
import 'notes_provider.dart';
import '../../core/theme/app_theme.dart';

class NoteEditor extends ConsumerStatefulWidget {
  final Note? note;
  final int? moduleId;
  const NoteEditor({super.key, this.note, this.moduleId});

  @override
  ConsumerState<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends ConsumerState<NoteEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: MiraTheme.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: MiraTheme.rule,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.note == null ? 'Nouvelle note' : 'Modifier la note',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: MiraTheme.charcoal,
            ),
          ),
          if (widget.moduleId != null) ...[
            const SizedBox(height: 4),
            Text(
              'Pour le Module ${widget.moduleId}',
              style: const TextStyle(color: MiraTheme.muted, fontSize: 14),
            ),
          ],
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            maxLines: 8,
            style: const TextStyle(fontSize: 16, height: 1.5),
            decoration: InputDecoration(
              hintText: 'Que souhaites-tu retenir ?',
              hintStyle: const TextStyle(color: MiraTheme.muted),
              filled: true,
              fillColor: MiraTheme.warmBeige.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final content = _controller.text.trim();
              if (content.isEmpty) return;

              if (widget.note == null) {
                ref.read(notesProvider.notifier).addNote(widget.moduleId ?? 1, content);
              } else {
                ref.read(notesProvider.notifier).updateNote(widget.note!.id, content);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Enregistrer la note'),
          ),
        ],
      ),
    );
  }
}
