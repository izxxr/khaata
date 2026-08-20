import 'package:flutter/material.dart';
import 'package:khaata/app/style.dart';


/// Accounts list widget for the "Accounts" section.
class AccountsList extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.globalPadding),
        children: [
          Text(
            "Accounts",
            style: Theme.of(context).textTheme.titleLarge
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            "Categorize your transactions using accounts",
            style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: Theme.of(context).hintColor),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - kToolbarHeight, 
            width: double.infinity,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: AppSpacing.md,
                children: [
                  Text(
                    "No accounts",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    "Tap on + to create an account",
                    style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Theme.of(context).hintColor),
                  ),
                ]
              )
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
