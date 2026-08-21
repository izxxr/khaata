import 'package:go_router/go_router.dart';
import 'package:khaata/app/app_shell.dart';
import 'package:khaata/app/bloc/app_bloc.dart';
import 'package:khaata/core/internal/go_router_refreshable_stream.dart';
import 'package:khaata/features/dashboard/presentation/dashboard.dart';
import 'package:khaata/features/onboarding/presentation/intro.dart';
import 'package:khaata/features/onboarding/presentation/setup.dart';
import 'package:khaata/features/onboarding/presentation/final.dart';
import 'package:khaata/features/accounts/presentation/accounts_list.dart';
import 'package:khaata/features/goals/presentation/goals.dart';
import 'package:khaata/features/settings/presentation/settings.dart';


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
}
