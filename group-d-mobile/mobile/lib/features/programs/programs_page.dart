import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import 'models/enrolment.dart';
import 'programmes_service.dart';

final programmesProvider = FutureProvider<ProgrammesResult>((ref) {
  return ref.read(programmesServiceProvider).fetchEnrolments();
});

class ProgramsPage extends ConsumerWidget {
  const ProgramsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programmesAsync = ref.watch(programmesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
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
                      height: 1,
                      fontSize: 28,
                    ),
              ),
              centerTitle: false,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            sliver: programmesAsync.when(
              data: (result) {
                if (result.enrolments.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Aucun programme pour le moment.',
                        style: TextStyle(color: MiraTheme.muted),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (result.isMocked && index == 0) {
                        return Column(
                          children: [
                            const _MockBanner(),
                            const SizedBox(height: 16),
                            _ProgramCard(enrolment: result.enrolments[index]),
                          ],
                        );
                      }
                      return _ProgramCard(enrolment: result.enrolments[index]);
                    },
                    childCount: result.enrolments.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: MiraTheme.miraRed),
                ),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Erreur: $err'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.enrolment});

  final Enrolment enrolment;

  @override
  Widget build(BuildContext context) {
    final program = enrolment.program;
    final dateLabel = _buildDateLabel(program.startsAt, program.endsAt);
    final progress = program.progressPct ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: MiraTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MiraTheme.rule),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/program/${program.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              width: double.infinity,
              color: MiraTheme.warmBeige,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          program.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: MiraTheme.charcoal,
                          ),
                        ),
                      ),
                      _StatusChip(status: enrolment.status),
                    ],
                  ),
                  if (program.mentorName != null)
                    Text(
                      'avec ${program.mentorName}',
                      style: const TextStyle(color: MiraTheme.muted),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: progress / 100,
                            backgroundColor: MiraTheme.rule,
                            valueColor: const AlwaysStoppedAnimation<Color>(MiraTheme.miraRed),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$progress%',
                        style: const TextStyle(
                          color: MiraTheme.miraRed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      if (program.city != null)
                        _InfoPill(icon: Icons.location_on_outlined, label: program.city!),
                      if (dateLabel != null)
                        _InfoPill(icon: Icons.calendar_today_outlined, label: dateLabel),
                      if (program.moduleCount != null)
                        _InfoPill(
                          icon: Icons.view_list_outlined,
                          label: '${program.moduleCount} modules',
                        ),
                    ],
                  ),
                  if (program.nextModuleTitle != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Prochain module',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: MiraTheme.charcoal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      program.nextModuleTitle!,
                      style: const TextStyle(color: MiraTheme.muted, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _buildDateLabel(DateTime? startsAt, DateTime? endsAt) {
    if (startsAt == null) return null;
    final formatter = DateFormat('d MMM', 'fr');
    final start = formatter.format(startsAt);
    if (endsAt == null) return start;
    return '$start - ${formatter.format(endsAt)}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final style = switch (status) {
      'accepted' => (MiraTheme.success, 'Actif'),
      'completed' => (Colors.blueGrey, 'Termine'),
      'waitlist' => (Colors.orange, 'Waitlist'),
      _ => (MiraTheme.muted, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: style.$1.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        style.$2,
        style: TextStyle(color: style.$1, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: MiraTheme.warmBeige,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: MiraTheme.muted),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _MockBanner extends StatelessWidget {
  const _MockBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off_outlined, color: Color(0xFF8A6116)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Backend indisponible. Affichage temporaire de donnees de demo.',
              style: TextStyle(
                color: Color(0xFF8A6116),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
