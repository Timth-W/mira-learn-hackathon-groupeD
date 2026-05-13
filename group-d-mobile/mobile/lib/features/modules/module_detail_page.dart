import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../notes/note_editor.dart';

class ModuleDetailPage extends StatelessWidget {
  final String id;
  const ModuleDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final int moduleId = int.tryParse(id) ?? 0;

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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Module $id',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: MiraTheme.miraRed,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Introduction au freelancing', // Mock title
              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 32),
            ),
            const SizedBox(height: 24),

            // Video Placeholder "Premium"
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: MiraTheme.charcoal,
                borderRadius: BorderRadius.circular(24),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=800&q=80'),
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
              'Résumé du module',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: MiraTheme.charcoal),
            ),
            const SizedBox(height: 12),
            const Text(
              'Dans ce module, nous allons explorer les bases du sujet. '
              'Vous apprendrez les concepts fondamentaux et comment les appliquer dans des cas réels.',
              style: TextStyle(fontSize: 15, height: 1.6, color: MiraTheme.charcoal),
            ),

            const SizedBox(height: 32),

            const Text(
              'Ressources',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: MiraTheme.charcoal),
            ),
            const SizedBox(height: 12),
            _buildResourceItem(context, Icons.picture_as_pdf_outlined, 'Guide complet du module', 'PDF • 2.4 MB'),

            const SizedBox(height: 40),

            // Actions CTA
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => NoteEditor(moduleId: moduleId),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Le QCM sera bientôt disponible !')),
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

  Widget _buildResourceItem(BuildContext context, IconData icon, String title, String subtitle) {
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
