import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class MiraAvatar extends StatelessWidget {
  const MiraAvatar({
    super.key,
    required this.displayName,
    this.avatarUrl,
    this.size = 72,
  });

  final String displayName;
  final String? avatarUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = displayName
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .map((part) => part.trim()[0])
        .take(2)
        .join()
        .toUpperCase();

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: MiraTheme.beigeDeep,
        child: avatarUrl == null || avatarUrl!.isEmpty
            ? Center(
                child: Text(
                  initials.isEmpty ? 'M' : initials,
                  style: TextStyle(
                    color: MiraTheme.miraRed,
                    fontWeight: FontWeight.w800,
                    fontSize: size * 0.32,
                  ),
                ),
              )
            : Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Text(
                    initials.isEmpty ? 'M' : initials,
                    style: TextStyle(
                      color: MiraTheme.miraRed,
                      fontWeight: FontWeight.w800,
                      fontSize: size * 0.32,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class MiraEmptyState extends StatelessWidget {
  const MiraEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: MiraTheme.muted),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: MiraTheme.muted, height: 1.5),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class MiraSkeletonList extends StatefulWidget {
  const MiraSkeletonList({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  State<MiraSkeletonList> createState() => _MiraSkeletonListState();
}

class _MiraSkeletonListState extends State<MiraSkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final alpha = 0.35 + (_controller.value * 0.3);
        return Column(
          children: [
            for (var i = 0; i < widget.itemCount; i++) ...[
              _SkeletonCard(alpha: alpha),
              if (i != widget.itemCount - 1) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.alpha});

  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MiraTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MiraTheme.rule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bar(width: 160, height: 14),
          const SizedBox(height: 12),
          _bar(width: double.infinity, height: 10),
          const SizedBox(height: 8),
          _bar(width: 220, height: 10),
        ],
      ),
    );
  }

  Widget _bar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: MiraTheme.beigeDeep.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class MiraSkillChip extends StatelessWidget {
  const MiraSkillChip({
    super.key,
    required this.label,
    this.validated = false,
  });

  final String label;
  final bool validated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: validated ? MiraTheme.pastelSage : MiraTheme.beigeDeep,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (validated) ...[
            const Icon(Icons.star_outline, size: 14, color: MiraTheme.charcoal),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              color: MiraTheme.charcoal,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
