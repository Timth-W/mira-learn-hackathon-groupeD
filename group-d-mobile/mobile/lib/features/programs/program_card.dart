import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'program_model.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';

class ProgramCard extends StatelessWidget {
  final Program program;

  const ProgramCard({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
            if (program.bannerUrl != null)
              Image.network(
                program.bannerUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 120,
                width: double.infinity,
                color: MiraTheme.warmBeige,
                child: const Icon(Icons.auto_stories_outlined,
                  size: 40, color: MiraTheme.muted),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          program.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: MiraTheme.charcoal,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: MiraTheme.warmBeige,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${program.progress}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: MiraTheme.miraRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'avec ${program.mentor}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: MiraTheme.muted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: program.progress / 100,
                      minHeight: 6,
                      backgroundColor: MiraTheme.rule,
                      valueColor: const AlwaysStoppedAnimation<Color>(MiraTheme.miraRed),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: MiraTheme.muted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Prochaine session : ${DateFormat('dd MMMM à HH:mm', 'fr').format(program.nextSession)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: MiraTheme.charcoal,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, size: 18, color: MiraTheme.miraRed),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
