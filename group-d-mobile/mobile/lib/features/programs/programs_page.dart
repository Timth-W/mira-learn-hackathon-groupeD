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
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: MiraTheme.warmBeige,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text(
                'Mes Programmes',
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
            sliver: programsAsync.when(
              data: (programs) => programs.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(child: Text('Aucun programme trouvé')),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ProgramCard(program: programs[index]);
                        },
                        childCount: programs.length,
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
    );
  }
}
