import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/app/bloc/app_bloc.dart';
import 'package:khaata/app/bloc/app_event.dart';
import 'package:khaata/features/onboarding/presentation/banner.dart';


class OnboardingSetup extends StatefulWidget {
  const new({super.key});

  @override
  State<OnboardingSetup> createState() => _OnboardingSetupState();
}

class _OnboardingSetupState extends State<OnboardingSetup> {
  final usernameController = TextEditingController();
  String? errorText;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          OnboardingBanner(),
          SizedBox(height: 2 * AppSpacing.xl),
          Text(
            "What should we call you?",
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md),
          SizedBox(
            width: 360,
            child: Text(
              "This name will be used to refer to you in transactions and various places in the app.",
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
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                label: Text("Username"),
                errorText: errorText,
              ),
              controller: usernameController,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: () {
              final value = usernameController.text.trim();

              if (value.isEmpty) {
                return setState(() {
                  errorText = "Required";
                });
              }

              if (value.length < 2) {
                return setState(() {
                  errorText = "Must be at least 2 characters";
                });
              }

              if (value.length > 32) {
                return setState(() {
                  errorText = "Must be less than 32 characters";
                });
              }

              context.read<AppBloc>().add(UsernameUpdated(newUsername: value));
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
          SizedBox(height: AppSpacing.xl),
          Text(
            "You can always change this later.",
            style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: Theme.of(context).hintColor,),
          ),
        ],
      )
    );
  }
}