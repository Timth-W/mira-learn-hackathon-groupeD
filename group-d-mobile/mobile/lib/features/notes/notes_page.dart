import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import 'note_card.dart';
import 'note_editor.dart';
import 'note_model.dart';
import 'notes_provider.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  String? _selectedModuleId;
  String? _selectedConcept;
  NoteOrganization? _organization;
  bool _organizing = false;

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);

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
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              expandedTitleScale: 1.3,
              title: Text(
                'Notes IA\n& concepts',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      height: 1.0,
                      fontSize: 28,
                    ),
              ),
              centerTitle: false,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: notesAsync.when(
              data: (notes) {
                final visibleNotes = _filterNotes(notes);
                if (notes.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyNotes(
                        onCreate: () => _showAddNoteDialog(context)),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) {
                        return _NotesDemoHeader(
                          notes: notes,
                          modules: _moduleIds(notes),
                          concepts: _concepts(notes),
                          selectedModuleId: _selectedModuleId,
                          selectedConcept: _selectedConcept,
                          organization: _organization,
                          organizing: _organizing,
                          onModuleChanged: (value) =>
                              setState(() => _selectedModuleId = value),
                          onConceptChanged: (value) =>
                              setState(() => _selectedConcept = value),
                          onOrganize: () => _organize(visibleNotes),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: NoteCard(note: visibleNotes[index - 1]),
                      );
                    },
                    childCount: visibleNotes.length + 1,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(color: MiraTheme.miraRed)),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(child: Text('Erreur: $err')),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        backgroundColor: MiraTheme.miraRed,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NoteEditor(),
    );
  }

  List<String> _moduleIds(List<Note> notes) {
    final ids =
        notes.map((note) => note.moduleId).whereType<String>().toSet().toList();
    ids.sort();
    return ids;
  }

  List<String> _concepts(List<Note> notes) {
    final tags = notes.expand((note) => note.tags).toSet().toList();
    tags.sort();
    return tags;
  }

  List<Note> _filterNotes(List<Note> notes) {
    return notes.where((note) {
      final moduleOk =
          _selectedModuleId == null || note.moduleId == _selectedModuleId;
      final conceptOk =
          _selectedConcept == null || note.tags.contains(_selectedConcept);
      return moduleOk && conceptOk;
    }).toList(growable: false);
  }

  Future<void> _organize(List<Note> visibleNotes) async {
    if (visibleNotes.isEmpty || _organizing) return;
    setState(() => _organizing = true);
    try {
      final classId = visibleNotes.first.classId;
      final organization = await ref.read(notesProvider.notifier).organizeNotes(
            classId: classId,
            moduleId: _selectedModuleId,
          );
      if (!mounted) return;
      setState(() {
        _organization = organization;
        _organizing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _organizing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Organisation IA indisponible: $e')),
      );
    }
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.note_alt_outlined,
              size: 64, color: MiraTheme.mutedSoft),
          const SizedBox(height: 16),
          const Text(
            'Aucune note pour le moment.\nQue souhaites-tu retenir ?',
            textAlign: TextAlign.center,
            style: TextStyle(color: MiraTheme.muted, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 220,
            child: OutlinedButton(
              onPressed: onCreate,
              child: const Text('Creer ma premiere note'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesDemoHeader extends StatelessWidget {
  const _NotesDemoHeader({
    required this.notes,
    required this.modules,
    required this.concepts,
    required this.selectedModuleId,
    required this.selectedConcept,
    required this.organization,
    required this.organizing,
    required this.onModuleChanged,
    required this.onConceptChanged,
    required this.onOrganize,
  });

  final List<Note> notes;
  final List<String> modules;
  final List<String> concepts;
  final String? selectedModuleId;
  final String? selectedConcept;
  final NoteOrganization? organization;
  final bool organizing;
  final ValueChanged<String?> onModuleChanged;
  final ValueChanged<String?> onConceptChanged;
  final VoidCallback onOrganize;

  @override
  Widget build(BuildContext context) {
    final filteredCount = notes.where((note) {
      final moduleOk =
          selectedModuleId == null || note.moduleId == selectedModuleId;
      final conceptOk =
          selectedConcept == null || note.tags.contains(selectedConcept);
      return moduleOk && conceptOk;
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatsBand(notes: notes, filteredCount: filteredCount),
        const SizedBox(height: 16),
        _FilterWrap(
          allLabel: 'Tous modules',
          values: modules,
          selectedValue: selectedModuleId,
          valueLabel: _moduleLabel,
          onChanged: onModuleChanged,
        ),
        const SizedBox(height: 12),
        _FilterWrap(
          allLabel: 'Tous concepts',
          values: concepts,
          selectedValue: selectedConcept,
          valueLabel: (value) => '#$value',
          onChanged: onConceptChanged,
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: organizing ? null : onOrganize,
            icon: organizing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.auto_awesome_rounded, size: 20),
            label: Text(organizing ? 'Generation...' : 'Generer une fiche IA'),
          ),
        ),
        if (organization != null) ...[
          const SizedBox(height: 16),
          _OrganizationPanel(organization: organization!),
        ],
      ],
    );
  }

  static String _moduleLabel(String value) {
    final prefix = value.length >= 4 ? value.substring(0, 4) : value;
    final suffix = value.length >= 4 ? value.substring(value.length - 4) : value;
    return 'Module $prefix-$suffix';
  }
}

class _FilterWrap extends StatelessWidget {
  const _FilterWrap({
    required this.allLabel,
    required this.values,
    required this.selectedValue,
    required this.valueLabel,
    required this.onChanged,
  });

  final String allLabel;
  final List<String> values;
  final String? selectedValue;
  final String Function(String value) valueLabel;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: Text(
            allLabel,
            style: TextStyle(
              color: selectedValue == null ? Colors.white : MiraTheme.charcoal,
              fontWeight: FontWeight.w500,
            ),
          ),
          selected: selectedValue == null,
          selectedColor: MiraTheme.miraRed,
          backgroundColor: MiraTheme.cardBg,
          checkmarkColor: Colors.white,
          side: const BorderSide(color: MiraTheme.mutedSoft),
          onSelected: (_) => onChanged(null),
        ),
        for (final value in values)
          ChoiceChip(
            label: Text(
              valueLabel(value),
              style: TextStyle(
                color: selectedValue == value ? Colors.white : MiraTheme.charcoal,
                fontWeight: FontWeight.w500,
              ),
            ),
            selected: selectedValue == value,
            selectedColor: MiraTheme.miraRed,
            backgroundColor: MiraTheme.cardBg,
            checkmarkColor: Colors.white,
            side: const BorderSide(color: MiraTheme.mutedSoft),
            onSelected: (_) => onChanged(value),
          ),
      ],
    );
  }
}

class _StatsBand extends StatelessWidget {
  const _StatsBand({required this.notes, required this.filteredCount});

  final List<Note> notes;
  final int filteredCount;

  @override
  Widget build(BuildContext context) {
    final favoriteCount = notes.where((note) => note.isFavorite).length;
    final conceptCount = notes.expand((note) => note.tags).toSet().length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MiraTheme.charcoal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
              child: _Metric(value: '$filteredCount', label: 'notes visibles')),
          Expanded(child: _Metric(value: '$conceptCount', label: 'concepts')),
          Expanded(child: _Metric(value: '$favoriteCount', label: 'favoris')),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(label,
            style: const TextStyle(color: MiraTheme.mutedSoft, fontSize: 12)),
      ],
    );
  }
}

class _OrganizationPanel extends StatelessWidget {
  const _OrganizationPanel({required this.organization});

  final NoteOrganization organization;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MiraTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MiraTheme.rule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  color: MiraTheme.miraRed, size: 20),
              SizedBox(width: 8),
              Text(
                'Fiche de revision IA',
                style: TextStyle(
                    fontWeight: FontWeight.w800, color: MiraTheme.charcoal),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Resume',
            style:
                TextStyle(fontWeight: FontWeight.w800, color: MiraTheme.charcoal),
          ),
          const SizedBox(height: 4),
          Text(organization.summary, style: const TextStyle(height: 1.4)),
          const SizedBox(height: 12),
          if (organization.keyTakeaways.isNotEmpty) ...[
            const Text(
              'A retenir',
              style: TextStyle(
                  fontWeight: FontWeight.w800, color: MiraTheme.charcoal),
            ),
            const SizedBox(height: 6),
            for (final takeaway in organization.keyTakeaways.take(4))
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('- $takeaway',
                    style:
                        const TextStyle(color: MiraTheme.muted, height: 1.35)),
              ),
            const SizedBox(height: 12),
          ],
          const Text(
            'Concepts reformules',
            style:
                TextStyle(fontWeight: FontWeight.w800, color: MiraTheme.charcoal),
          ),
          const SizedBox(height: 8),
          for (final concept in organization.concepts.take(3)) ...[
            Text(
              concept.name,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: MiraTheme.miraRed),
            ),
            const SizedBox(height: 4),
            if (concept.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(concept.description,
                    style:
                        const TextStyle(color: MiraTheme.charcoal, height: 1.35)),
              ),
            for (final point in concept.keyPoints.take(2))
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('- $point',
                    style:
                        const TextStyle(color: MiraTheme.muted, height: 1.35)),
              ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
