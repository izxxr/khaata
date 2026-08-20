import 'package:go_router/go_router.dart';
import 'package:khaata/app/app_shell.dart';
import 'package:khaata/features/dashboard/presentation/dashboard.dart';
import 'package:khaata/features/accounts/presentation/accounts_list.dart';
import 'package:khaata/features/goals/presentation/goals.dart';
import 'package:khaata/features/settings/presentation/settings.dart';


/// The application router.
/// 
/// The routes are structured using StatefulShellRoute (based on indexed stack)
/// to preserve stateful navigation of top level pages.
final router = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const Dashboard(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/accounts',
              builder: (context, state) => const AccountsList(),
              // routes: [
              //   GoRoute(
              //     path: ':id',
              //     builder: (context, state) {
              //       final id = state.pathParameters['id']!;
              //       return Acc(id: id);
              //     },
              //   ),
              // ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/goals',
              builder: (context, state) => const Goals(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const Settings(),
            ),
          ],
        ),
      ],
    ),
  ],
);