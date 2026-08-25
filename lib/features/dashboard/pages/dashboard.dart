import 'package:flutter/material.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/features/dashboard/widgets/overview_card.dart';
import 'package:khaata/features/dashboard/widgets/quick_actions.dart';
import 'package:khaata/features/transactions/widgets/transactions_list.dart';


/// Dashboard widget for the home screen.
class Dashboard extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          OverviewCard(),
          SizedBox(height: AppSpacing.lg),
          QuickActions(),
          Expanded(
            child: Padding(
              padding: EdgeInsetsGeometry.all(AppSpacing.globalPadding),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Recent Transactions",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      // TODO: reveal this after insights page implemented
                      // Spacer(),
                      // TextButton.icon(
                      //   onPressed: () {},
                      //   label: Text("View all"),
                      // ),
                    ]
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Flexible(child: TransactionsList(limit: 4)),
                  SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ]
      )
    );
  }
}
