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
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: MiraTheme.warmBeige,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text(
                'Mes Notes',
                style: TextStyle(
                  color: MiraTheme.charcoal,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
              centerTitle: false,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            sliver: notesAsync.when(
              data: (notes) => notes.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.note_alt_outlined, size: 64, color: MiraTheme.muted),
                            SizedBox(height: 16),
                            Text('Aucune note pour le moment', style: TextStyle(color: MiraTheme.muted)),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return NoteCard(note: notes[index]);
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
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const NoteEditor(),
          );
        },
        backgroundColor: MiraTheme.miraRed,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add_rounded, size: 32),
      ),
    );
  }
}
