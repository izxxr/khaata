import 'package:go_router/go_router.dart';
import 'package:khaata/helpers/go_router_refreshable_stream.dart';
import 'package:khaata/app/app_shell.dart';
import 'package:khaata/app/bloc/app_bloc.dart';
import 'package:khaata/features/dashboard/pages/dashboard.dart';
import 'package:khaata/features/onboarding/pages/intro.dart';
import 'package:khaata/features/onboarding/pages/setup.dart';
import 'package:khaata/features/onboarding/pages/final.dart';
import 'package:khaata/features/accounts/pages/accounts_list.dart';
import 'package:khaata/features/accounts/pages/account_view.dart';
import 'package:khaata/features/insights/pages/insights.dart';
import 'package:khaata/features/settings/pages/settings.dart';
import 'package:khaata/features/transactions/pages/categories.dart';


/// Build the application router.
/// 
/// The routes are structured using StatefulShellRoute (based on indexed stack)
/// to preserve stateful navigation of top level pages.
GoRouter createRouter(AppBloc appBloc) {
  return GoRouter(
    refreshListenable: GoRouterRefreshStream(appBloc.stream),
    redirect: (context, state) {
      final onboardingComplete = appBloc.state.onboardingComplete;
      final isOnboarding = state.matchedLocation.startsWith('/onboarding');

      if (!onboardingComplete && !isOnboarding) {
        return '/onboarding';
      }

      if (onboardingComplete && isOnboarding) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingIntro(),
        routes: [
          GoRoute(
            path: 'setup',
            builder: (context, state) => const OnboardingSetup(),
          ),
          GoRoute(
            path: 'final',
            builder: (context, state) => const OnboardingFinal(),
          )
        ]
      ),
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
                routes: [
                  GoRoute(
                    path: '/categories',
                    builder: (context, state) => const Categories(),
                  ),
                ]
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/accounts',
                builder: (context, state) => const AccountsList(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final int? id = int.tryParse(state.pathParameters['id']!);

                      if (id == null) {
                        return const Dashboard();
                      } else {
                        return AccountView(accountId: id);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/insights',
                builder: (context, state) => const Insights(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => Settings(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
