import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'program_detail_provider.dart';
import 'package:go_router/go_router.dart';

class ProgramDetailPage extends ConsumerWidget {
  final String id;
  const ProgramDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programAsync = ref.watch(programDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Programme'),
      ),
      body: programAsync.when(
        data: (program) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(program.title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(program.description),
              const SizedBox(height: 24),
              Text('Progression globale: ${program.globalProgress}%'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: program.globalProgress / 100),
              const SizedBox(height: 32),
              Text('Modules', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ...program.modules.map((module) => Card(
                child: ListTile(
                  leading: Icon(module.isLocked ? Icons.lock : Icons.play_circle_fill),
                  title: Text(module.title),
                  subtitle: Text('Durée: ${module.duration} • ${module.progress}%'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: module.isLocked ? null : () => context.push('/module/${module.id}'),
                  enabled: !module.isLocked,
                ),
              )),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }
}
