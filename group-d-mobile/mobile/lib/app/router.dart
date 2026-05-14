import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/login/login_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/programs/programs_page.dart';
import '../features/programs/program_detail_page.dart';
import '../features/modules/module_detail_page.dart';
import '../features/notes/notes_page.dart';
import 'providers/auth_provider.dart';
import '../core/theme/app_theme.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshNotifier(ref),
    redirect: (context, state) {
      if (auth.isLoading) {
        return state.matchedLocation == '/splash' ? null : '/splash';
      }

      final loggedIn = auth.maybeWhen(
        data: (s) => s is MiraAuthAuthenticated,
        orElse: () => false,
      );
      final isOnSplash = state.matchedLocation == '/splash';
      final isOnLogin = state.matchedLocation == '/login';

      if (isOnSplash) {
        return loggedIn ? '/' : '/login';
      }
      if (!loggedIn && !isOnLogin) return '/login';
      if (loggedIn && isOnLogin) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => Scaffold(
          body: child,
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: MiraTheme.rule, width: 0.5)),
            ),
            child: BottomNavigationBar(
              currentIndex: _calculateSelectedIndex(state.matchedLocation),
              elevation: 0,
              backgroundColor: MiraTheme.cardBg,
              selectedItemColor: MiraTheme.miraRed,
              unselectedItemColor: MiraTheme.muted,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                if (index == 0) context.go('/');
                if (index == 1) context.go('/notes');
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.auto_stories_outlined),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.auto_stories),
                  ),
                  label: 'Programmes',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.note_alt_outlined),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.note_alt),
                  ),
                  label: 'Notes',
                ),
              ],
            ),
          ),
        ),
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const ProgramsPage(),
          ),
          GoRoute(
            path: '/notes',
            builder: (_, __) => const NotesPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/program/:id',
        builder: (context, state) => ProgramDetailPage(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/module/:id',
        builder: (context, state) => ModuleDetailPage(
          id: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});

int _calculateSelectedIndex(String location) {
  if (location.startsWith('/notes')) return 1;
  return 0;
}

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    ref.listen(authNotifierProvider, (_, __) => notifyListeners());
  }
}
