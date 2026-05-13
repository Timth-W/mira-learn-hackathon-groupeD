import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import 'models/enrolment.dart';
import 'programmes_service.dart';

class ProgrammesScreen extends ConsumerStatefulWidget {
  const ProgrammesScreen({super.key});

  @override
  ConsumerState<ProgrammesScreen> createState() => _ProgrammesScreenState();
}

class _ProgrammesScreenState extends ConsumerState<ProgrammesScreen> {
  late Future<ProgrammesResult> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(programmesServiceProvider).fetchEnrolments();
  }

  Future<void> _reload() async {
    setState(() {
      _future = ref.read(programmesServiceProvider).fetchEnrolments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Programmes')),
      body: FutureBuilder<ProgrammesResult>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ProgrammesErrorState(
              onRetry: _reload,
              message: 'Impossible de charger les programmes pour le moment.',
            );
          }

          final result = snapshot.data!;
          if (result.enrolments.isEmpty) {
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 120),
                  Icon(
                    Icons.menu_book_outlined,
                    size: 48,
                    color: MiraTheme.muted,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucun programme pour le moment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (result.isMocked)
                  const _MockBanner(),
                for (final enrolment in result.enrolments)
                  _ProgramCard(enrolment: enrolment),
              ],
            ),
          );
        },
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        program.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      if (program.mentorName != null)
                        Text(
                          'Mentor: ${program.mentorName}',
                          style: const TextStyle(color: MiraTheme.muted),
                        ),
                    ],
                  ),
                ),
                _StatusChip(status: enrolment.status),
              ],
            ),
            const SizedBox(height: 14),
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
              const SizedBox(height: 14),
              Text(
                'Prochain module',
                style: Theme.of(context).textTheme.labelLarge,
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
      'accepted' => (MiraTheme.success, 'Accepte'),
      'completed' => (Colors.blueGrey, 'Termine'),
      'waitlist' => (Colors.orange, 'Liste attente'),
      'applied' => (Colors.blue, 'En attente'),
      'cancelled' => (MiraTheme.error, 'Annule'),
      'rejected' => (MiraTheme.error, 'Refuse'),
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
        style: TextStyle(
          color: style.$1,
          fontWeight: FontWeight.w600,
        ),
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
        color: const Color(0xFFF3EFEA),
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

class _ProgrammesErrorState extends StatelessWidget {
  const _ProgrammesErrorState({
    required this.onRetry,
    required this.message,
  });

  final Future<void> Function() onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: MiraTheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Reessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
