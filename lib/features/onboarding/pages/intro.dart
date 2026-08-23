import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/features/onboarding/widgets/banner.dart';

class OnboardingIntro extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              OnboardingBanner(),
              SizedBox(height: 2 * AppSpacing.xl),
              Text(
                "Your Expenses,\nManaged Perfectly",
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                "We will quickly setup the app for first use",
                style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                                color: Theme.of(context).hintColor,
                              ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2 * AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: () {
                  context.go("/onboarding/setup");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  fixedSize: Size(140, 50),
                ),
                icon: Icon(Icons.arrow_right_alt, size: 24),
                iconAlignment: IconAlignment.end,
                label: Text("Continue"),
              )
            ],
          )
        )
      )
    );
  }
}