import 'package:go_router/go_router.dart';
import '../../features/timetable/presentation/timetable_home_page.dart';
import '../../features/import/presentation/import_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TimetableHomePage(),
    ),
    GoRoute(
      path: '/import',
      builder: (context, state) => const ImportPage(),
    ),
    // 预留来源管理页面路由
    GoRoute(
      path: '/sources',
      builder: (context, state) {
        throw UnimplementedError('SourcesPage is not implemented yet');
      },
    ),
  ],
);
