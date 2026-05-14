import 'package:go_router/go_router.dart';
import '../../features/timetable/presentation/timetable_home_page.dart';
import '../../features/import/presentation/import_page.dart';
import '../../features/source/presentation/source_list_page.dart';
import '../../features/source/presentation/source_detail_page.dart';

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
