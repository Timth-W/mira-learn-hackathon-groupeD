import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import 'programs_provider.dart';
import 'program_card.dart';

class ProgramsPage extends ConsumerWidget {
  const ProgramsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsAsync = ref.watch(programsProvider);

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
                'Mes\nProgrammes',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  height: 1.0,
                  fontSize: 28, // Ajusté pour le rendu Sliver
                ),
              ),
              centerTitle: false,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            sliver: programsAsync.when(
              data: (programs) => programs.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Aucun programme pour le moment.',
                          style: TextStyle(color: MiraTheme.muted),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: ProgramCard(program: programs[index]),
                          );
                        },
                        childCount: programs.length,
                      ),
                    ),
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: MiraTheme.miraRed),
                ),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(child: Text('Erreur: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
