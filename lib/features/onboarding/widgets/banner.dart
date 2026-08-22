import 'package:flutter/material.dart';
import 'package:khaata/app/style.dart';

class OnboardingBanner extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.inversePrimary,
            Theme.of(context).colorScheme.primaryContainer,
          ]
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Spacer(),
            Icon(Icons.account_balance, size: 128),
            SizedBox(height: AppSpacing.md),
            Text(
              "Khaata",
              style: Theme.of(context)
                           .textTheme
                           .displaySmall
                          ?.copyWith(fontWeight: FontWeight.bold)
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}