import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/timetable/presentation/timetable_home_page.dart';
import '../../features/import/presentation/import_page.dart';
import '../../features/source/presentation/source_list_page.dart';
import '../../features/source/presentation/source_detail_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/auth/application/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final token = ref.watch(tokenProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isLoggedIn = token != null && token.isNotEmpty;

      // 如果未登录且没有在登录/注册页面，重定向到登录页
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // 如果已登录且还在登录页，重定向到首页
      if (isLoggedIn && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const TimetableHomePage(),
      ),
      GoRoute(path: '/import', builder: (context, state) => const ImportPage()),
      GoRoute(
        path: '/sources',
        builder: (context, state) => const SourceListPage(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return SourceDetailPage(sourceId: id);
            },
          ),
        ],
      ),
    ],
  );
});
