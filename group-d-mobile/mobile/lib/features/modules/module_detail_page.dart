import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../notes/note_editor.dart';

class ModuleDetailPage extends StatelessWidget {
  const ModuleDetailPage({
    super.key,
    required this.id,
    this.classId,
    this.title,
    this.description,
    this.duration,
    this.quizId,
  });

  final String id;
  final String? classId;
  final String? title;
  final String? description;
  final String? duration;
  final String? quizId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MiraTheme.warmBeige,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Module ${id.substring(0, id.length > 8 ? 8 : id.length)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: MiraTheme.miraRed,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              title ?? 'Module Mira Learn',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 32),
            ),
            if (duration != null) ...[
              const SizedBox(height: 8),
              Text(
                duration!,
                style: const TextStyle(color: MiraTheme.muted, fontSize: 14),
              ),
            ],
            const SizedBox(height: 24),
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: MiraTheme.charcoal,
                borderRadius: BorderRadius.circular(24),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=800&q=80',
                  ),
                  fit: BoxFit.cover,
                  opacity: 0.6,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: MiraTheme.miraRed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Resume du module',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: MiraTheme.charcoal,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description ??
                  'Dans ce module, nous allons explorer les bases du sujet et les appliquer a des cas reels.',
              style: const TextStyle(fontSize: 15, height: 1.6, color: MiraTheme.charcoal),
            ),
            const SizedBox(height: 32),
            const Text(
              'Ressources',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: MiraTheme.charcoal,
              ),
            ),
            const SizedBox(height: 12),
            _buildResourceItem(
              Icons.picture_as_pdf_outlined,
              'Support du module',
              'PDF • Acces rapide',
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => NoteEditor(
                          moduleId: id,
                          classId: classId,
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_note_rounded, size: 20),
                    label: const Text('Note'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (quizId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Le QCM sera bientot disponible !')),
                        );
                        return;
                      }
                      context.push(
                        Uri(
                          path: '/quiz/$quizId',
                          queryParameters: {
                            if (classId != null) 'classId': classId!,
                            'moduleId': id,
                            if (title != null) 'title': title!,
                          },
                        ).toString(),
                      );
                    },
                    icon: const Icon(Icons.quiz_outlined, size: 20),
                    label: const Text('QCM'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MiraTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MiraTheme.rule),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MiraTheme.warmBeige,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: MiraTheme.muted, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: MiraTheme.muted, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.download_rounded, color: MiraTheme.muted, size: 20),
        ],
      ),
    );
  }
}
