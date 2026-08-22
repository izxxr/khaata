import 'package:flutter/material.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/database/database.dart';

class AccountOverviewCard extends StatelessWidget {
  const new({super.key, required this.account});

  final AccountData account;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(5)
      ),
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Balance",
                style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Theme.of(context).hintColor)
              ),
              SizedBox(height: AppSpacing.sm),
              Text("54.00", style: Theme.of(context).textTheme.displaySmall),
            ]
          ),
          Spacer(),
          IconButton(onPressed: () {}, icon: Icon(Icons.refresh)),
        ],
      ),
    );
  }
}