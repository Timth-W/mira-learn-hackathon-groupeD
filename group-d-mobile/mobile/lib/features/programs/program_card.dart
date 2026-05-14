import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import 'program_model.dart';

class ProgramCard extends StatelessWidget {
  const ProgramCard({
    super.key,
    required this.program,
  });

  final Program program;

  @override
  Widget build(BuildContext context) {
    final progress = (program.progressPct ?? 0).clamp(0, 100);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: MiraTheme.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: MiraTheme.rule),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.push('/program/${program.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                program.title,
                style: const TextStyle(
                  color: MiraTheme.charcoal,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (program.mentorName != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Mentor: ${program.mentorName}',
                  style: const TextStyle(color: MiraTheme.muted),
                ),
              ],
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: progress / 100,
                  backgroundColor: MiraTheme.rule,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    MiraTheme.miraRed,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ProgramPill(
                    icon: Icons.trending_up,
                    label: '$progress%',
                  ),
                  if (program.city != null)
                    _ProgramPill(
                      icon: Icons.location_on_outlined,
                      label: program.city!,
                    ),
                  if (program.moduleCount != null)
                    _ProgramPill(
                      icon: Icons.view_list_outlined,
                      label: '${program.moduleCount} modules',
                    ),
                ],
              ),
              if (program.nextModuleTitle != null) ...[
                const SizedBox(height: 14),
                const Text(
                  'Next module',
                  style: TextStyle(
                    color: MiraTheme.charcoal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  program.nextModuleTitle!,
                  style: const TextStyle(color: MiraTheme.muted),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgramPill extends StatelessWidget {
  const _ProgramPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: MiraTheme.warmBeige,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: MiraTheme.rule),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: MiraTheme.muted),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: MiraTheme.charcoal,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
