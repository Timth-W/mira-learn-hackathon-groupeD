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
        title: Text('Module $id'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Placeholder "Premium"
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: MiraTheme.charcoal,
                borderRadius: BorderRadius.circular(20),
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
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Text(
                      'Introduction au sujet • 14:20',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

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
            _buildResourceItem(context, Icons.link_rounded, 'Lien vers la documentation officielle', 'Site Web'),

            const SizedBox(height: 40),

            // Actions CTA
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => NoteEditor(moduleId: moduleId),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MiraTheme.cardBg,
                      foregroundColor: MiraTheme.charcoal,
                      side: const BorderSide(color: MiraTheme.rule),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_note_rounded, size: 20),
                        SizedBox(width: 8),
                        Text('Note'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Le QCM sera bientôt disponible !')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MiraTheme.miraRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.quiz_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('QCM'),
                      ],
                    ),
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
