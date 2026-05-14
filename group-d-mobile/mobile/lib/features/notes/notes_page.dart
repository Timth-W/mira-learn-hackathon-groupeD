import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import 'notes_provider.dart';
import 'note_card.dart';
import 'note_editor.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false,
            pinned: true,
            backgroundColor: MiraTheme.warmBeige,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              expandedTitleScale: 1.3,
              title: Text(
                'Mes\nNotes',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  height: 1.0,
                  fontSize: 28,
                ),
              ),
              centerTitle: false,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: notesAsync.when(
              data: (notes) => notes.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.note_alt_outlined, size: 64, color: MiraTheme.mutedSoft),
                            const SizedBox(height: 16),
                            const Text(
                              'Aucune note pour le moment.\nQue souhaites-tu retenir ?',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: MiraTheme.muted, height: 1.5),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: 200,
                              child: OutlinedButton(
                                onPressed: () => _showAddNoteDialog(context),
                                child: const Text('Créer ma première note'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: NoteCard(note: notes[index]),
                          );
                        },
                        childCount: notes.length,
                      ),
                    ),
              loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: MiraTheme.miraRed)),
                  ),
              error: (err, stack) => SliverFillRemaining(
                    child: Center(child: Text('Erreur: $err')),
                  ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        backgroundColor: MiraTheme.miraRed,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NoteEditor(),
    );
  }
}
