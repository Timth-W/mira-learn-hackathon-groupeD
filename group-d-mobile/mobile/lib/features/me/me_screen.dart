import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/mira_widgets.dart';
import 'profile_model.dart';
import 'profile_provider.dart';

class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final profile = ref.watch(profileProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 152,
            pinned: true,
            backgroundColor: MiraTheme.warmBeige,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              expandedTitleScale: 1.3,
              title: Text(
                'Profil',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      height: 1,
                      fontSize: 28,
                    ),
              ),
              centerTitle: false,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: auth.maybeWhen(
                    data: (state) => state is MiraAuthAuthenticated
                        ? profile.when(
                            data: (data) => _ProfileContent(profile: data),
                            loading: () => const MiraSkeletonList(itemCount: 4),
                            error: (error, stack) => _ProfileError(
                              onRetry: () => ref.invalidate(profileProvider),
                            ),
                          )
                        : const MiraEmptyState(
                            icon: Icons.lock_outline,
                            title: 'Tu es deconnecte.',
                            subtitle:
                                'Reconnecte-toi pour voir ton profil Mira.',
                          ),
                    orElse: () => const MiraSkeletonList(itemCount: 3),
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

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.profile});

  final ProfileSummary profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeaderCard(profile: profile),
        const SizedBox(height: 16),
        _StatsRow(profile: profile),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Badges',
          child: profile.badges.isEmpty
              ? const MiraEmptyState(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Aucun badge pour le moment.',
                  subtitle:
                      'Passe un QCM ou prends quelques notes pour debloquer le premier.',
                )
              : Column(
                  children: [
                    for (final badge in profile.badges) ...[
                      _BadgeTile(badge: badge),
                      if (badge != profile.badges.last)
                        const SizedBox(height: 12),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Skills validees',
          child: profile.validatedSkills.isEmpty
              ? const MiraEmptyState(
                  icon: Icons.star_outline,
                  title: 'Pas encore de skill validee.',
                  subtitle: 'Le prochain QCM reussi apparaitra ici.',
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final skill in profile.validatedSkills)
                      MiraSkillChip(
                        label: skill.scorePct == null
                            ? skill.name
                            : '${skill.name} - ${skill.scorePct}%',
                        validated: true,
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Skills visees',
          child: profile.targetSkills.isEmpty
              ? const MiraEmptyState(
                  icon: Icons.track_changes_outlined,
                  title: 'Aucune skill cible.',
                  subtitle: 'Choisis une Mira Class pour nourrir ton parcours.',
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final skill in profile.targetSkills)
                      MiraSkillChip(label: skill.name),
                  ],
                ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
          icon: const Icon(Icons.logout_outlined),
          label: const Text('Deconnexion'),
        ),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.profile});

  final ProfileSummary profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MiraTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MiraTheme.rule),
      ),
      child: Row(
        children: [
          MiraAvatar(
            displayName: profile.displayName,
            avatarUrl: profile.avatarUrl,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email ?? 'Compte Mira Learn',
                  style: const TextStyle(color: MiraTheme.muted),
                ),
                const SizedBox(height: 10),
                MiraSkillChip(label: profile.role),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.profile});

  final ProfileSummary profile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 420;
        final cards = [
          _StatCard(
            label: 'Classes',
            value: profile.activeClassCount.toString(),
          ),
          _StatCard(label: 'Notes', value: profile.noteCount.toString()),
          _StatCard(label: 'QCM', value: profile.quizCount.toString()),
        ];
        if (compact) {
          return Column(
            children: [
              for (final card in cards) ...[
                card,
                if (card != cards.last) const SizedBox(height: 8),
              ],
            ],
          );
        }
        return Row(
          children: [
            for (final card in cards) ...[
              Expanded(child: card),
              if (card != cards.last) const SizedBox(width: 8),
            ],
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MiraTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MiraTheme.rule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: MiraTheme.muted),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MiraTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MiraTheme.rule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});

  final ProfileBadge badge;

  @override
  Widget build(BuildContext context) {
    final color = switch (badge.tone) {
      'gold' => MiraTheme.gold,
      'success' => MiraTheme.success,
      _ => MiraTheme.muted,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(_iconFor(badge.icon), color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                badge.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: MiraTheme.charcoal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                badge.description,
                style: const TextStyle(color: MiraTheme.muted, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _iconFor(String icon) {
    return switch (icon) {
      'workspace_premium' => Icons.workspace_premium_outlined,
      'auto_stories' => Icons.auto_stories_outlined,
      'groups' => Icons.groups_outlined,
      _ => Icons.flag_outlined,
    };
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MiraEmptyState(
      icon: Icons.cloud_off_outlined,
      title: "Le profil n'a pas charge.",
      subtitle: 'On garde ton espace au chaud. Reessaie dans un instant.',
      action: OutlinedButton(
        onPressed: onRetry,
        child: const Text('Reessayer'),
      ),
    );
  }
}
