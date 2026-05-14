import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/mira_widgets.dart';
import 'community_models.dart';
import 'community_provider.dart';

enum _CommunityView { map, feed }

class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  _CommunityView _view = _CommunityView.feed;

  @override
  Widget build(BuildContext context) {
    final asyncResult = ref.watch(communityProvider);

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
                'Communaute',
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
                  child: asyncResult.when(
                    data: _buildContent,
                    loading: () => const MiraSkeletonList(itemCount: 4),
                    error: (error, stack) => MiraEmptyState(
                      icon: Icons.cloud_off_outlined,
                      title: 'La communaute n\'a pas repondu',
                      subtitle: 'Garde le cap, puis reessaie dans un instant.',
                      action: OutlinedButton(
                        onPressed: () => ref.invalidate(communityProvider),
                        child: const Text('Reessayer'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(CommunityResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (result.isMocked) ...[
          const _CommunityNotice(),
          const SizedBox(height: 16),
        ],
        SegmentedButton<_CommunityView>(
          segments: const [
            ButtonSegment(
              value: _CommunityView.feed,
              icon: Icon(Icons.format_list_bulleted_outlined),
              label: Text('Feed'),
            ),
            ButtonSegment(
              value: _CommunityView.map,
              icon: Icon(Icons.public_outlined),
              label: Text('Carte'),
            ),
          ],
          selected: {_view},
          onSelectionChanged: (selection) {
            setState(() => _view = selection.first);
          },
        ),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _view == _CommunityView.feed
              ? _FeedView(activities: result.activities)
              : _MapView(spots: result.spots),
        ),
      ],
    );
  }
}

class _FeedView extends StatelessWidget {
  const _FeedView({required this.activities});

  final List<CommunityActivity> activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const MiraEmptyState(
        icon: Icons.forum_outlined,
        title: 'Aucun mouvement pour le moment.',
        subtitle: 'Les validations et inscriptions apparaitront ici.',
      );
    }

    return Column(
      children: [
        for (final activity in activities) ...[
          _FeedItem(activity: activity),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _FeedItem extends StatelessWidget {
  const _FeedItem({required this.activity});

  final CommunityActivity activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MiraTheme.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: MiraTheme.rule),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: MiraTheme.warmBeige,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(
              _iconFor(activity.displayIcon),
              color: MiraTheme.miraRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.displayText,
                  style: const TextStyle(
                    color: MiraTheme.charcoal,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _relativeTime(activity.occurredAt),
                  style: const TextStyle(color: MiraTheme.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String? icon) {
    return switch (icon) {
      'workspace_premium' => Icons.workspace_premium_outlined,
      'person_add' => Icons.person_add_alt_outlined,
      'travel_explore' => Icons.travel_explore_outlined,
      'verified' => Icons.verified_outlined,
      'campaign' => Icons.campaign_outlined,
      'groups' => Icons.groups_outlined,
      _ => Icons.flag_outlined,
    };
  }

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date.toLocal());
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes.clamp(1, 59)} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    return DateFormat('d MMM', 'fr').format(date.toLocal());
  }
}

class _MapView extends StatelessWidget {
  const _MapView({required this.spots});

  final List<CommunityMapSpot> spots;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxWidth < 420 ? 280.0 : 360.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MiraTheme.cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: MiraTheme.rule),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: MiraTheme.miraRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Icon(
                          Icons.public_outlined,
                          color: MiraTheme.miraRed,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sessions actives',
                              style: TextStyle(
                                color: MiraTheme.charcoal,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_totalSessions(spots)} nomades en mouvement',
                              style: const TextStyle(
                                color: MiraTheme.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: height,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _MapPainter(spots: spots),
                          ),
                        ),
                        for (final spot in spots)
                          Positioned(
                            left: (constraints.maxWidth - 32) * spot.left - 20,
                            top: height * spot.top - 20,
                            child: _MapMarker(spot: spot),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final spot in spots)
                  MiraSkillChip(label: '${spot.city} - ${spot.count}'),
              ],
            ),
          ],
        );
      },
    );
  }

  int _totalSessions(List<CommunityMapSpot> spots) {
    return spots.fold<int>(0, (total, spot) => total + spot.count);
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.spot});

  final CommunityMapSpot spot;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: spot.label,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: MiraTheme.miraRed.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: MiraTheme.cardBg, width: 2),
          boxShadow: [
            BoxShadow(
              color: MiraTheme.miraRed.withValues(alpha: 0.18),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: MiraTheme.miraRed,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              spot.count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  const _MapPainter({required this.spots});

  final List<CommunityMapSpot> spots;

  @override
  void paint(Canvas canvas, Size size) {
    final seaPaint = Paint()
      ..color = MiraTheme.warmBeige.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8)),
      seaPaint,
    );

    final gridPaint = Paint()
      ..color = MiraTheme.beigeDeep.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(16, y), Offset(size.width - 16, y), gridPaint);
    }
    for (var i = 1; i < 6; i++) {
      final x = size.width * i / 6;
      canvas.drawLine(Offset(x, 16), Offset(x, size.height - 16), gridPaint);
    }

    final landPaint = Paint()
      ..color = MiraTheme.cardBg
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = MiraTheme.beigeDeep
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (final path in _landPaths(size)) {
      canvas.drawPath(path, landPaint);
      canvas.drawPath(path, borderPaint);
    }

    if (spots.length > 1) {
      final routePaint = Paint()
        ..color = MiraTheme.miraRed.withValues(alpha: 0.24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      for (var i = 0; i < spots.length - 1; i++) {
        final a =
            Offset(size.width * spots[i].left, size.height * spots[i].top);
        final b = Offset(
          size.width * spots[i + 1].left,
          size.height * spots[i + 1].top,
        );
        final control = Offset(
          (a.dx + b.dx) / 2,
          (a.dy + b.dy) / 2 - size.height * 0.12,
        );
        final route = Path()
          ..moveTo(a.dx, a.dy)
          ..quadraticBezierTo(control.dx, control.dy, b.dx, b.dy);
        canvas.drawPath(route, routePaint);
      }
    }
  }

  List<Path> _landPaths(Size size) {
    return [
      Path()
        ..moveTo(size.width * 0.12, size.height * 0.36)
        ..quadraticBezierTo(
          size.width * 0.22,
          size.height * 0.19,
          size.width * 0.36,
          size.height * 0.29,
        )
        ..quadraticBezierTo(
          size.width * 0.46,
          size.height * 0.36,
          size.width * 0.41,
          size.height * 0.52,
        )
        ..quadraticBezierTo(
          size.width * 0.26,
          size.height * 0.62,
          size.width * 0.14,
          size.height * 0.50,
        )
        ..close(),
      Path()
        ..moveTo(size.width * 0.38, size.height * 0.30)
        ..quadraticBezierTo(
          size.width * 0.51,
          size.height * 0.17,
          size.width * 0.67,
          size.height * 0.28,
        )
        ..quadraticBezierTo(
          size.width * 0.75,
          size.height * 0.45,
          size.width * 0.59,
          size.height * 0.55,
        )
        ..quadraticBezierTo(
          size.width * 0.45,
          size.height * 0.56,
          size.width * 0.38,
          size.height * 0.30,
        )
        ..close(),
      Path()
        ..moveTo(size.width * 0.66, size.height * 0.55)
        ..quadraticBezierTo(
          size.width * 0.78,
          size.height * 0.45,
          size.width * 0.88,
          size.height * 0.60,
        )
        ..quadraticBezierTo(
          size.width * 0.82,
          size.height * 0.75,
          size.width * 0.68,
          size.height * 0.69,
        )
        ..close(),
    ];
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.spots != spots;
  }
}

class _CommunityNotice extends StatelessWidget {
  const _CommunityNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MiraTheme.beigeDeep,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off_outlined, color: MiraTheme.charcoal),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Backend indisponible. Affichage temporaire du feed de demo.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
