import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/app/bloc/app_bloc.dart';
import 'package:khaata/app/bloc/app_event.dart';
import 'package:khaata/features/onboarding/widgets/banner.dart';


class OnboardingFinal extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          OnboardingBanner(),
          SizedBox(height: 2 * AppSpacing.xl),
          Icon(Icons.celebration, size: 80),
          SizedBox(height: AppSpacing.xl),
          Text(
            "You're all done!",
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md),
          SizedBox(
            width: 360,
            child: Text(
              "Enjoy using Khaata for managing your finances!",
              style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                              color: Theme.of(context).hintColor,
                            ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: () {
              context.read<AppBloc>().add(OnboardingCompleted());
              context.go("/onboarding/final");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              fixedSize: Size(140, 50),
            ),
            icon: Icon(Icons.arrow_right_alt, size: 24),
            iconAlignment: IconAlignment.end,
            label: Text("Continue"),
          ),
        ],
      )
    );
  }
}