import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/features/dashboard/widgets/quick_action_button.dart';
import 'package:khaata/features/transactions/widgets/transaction_modal.dart';

class QuickActions extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(AppSpacing.globalPadding),
      child: Flex(
        direction: Axis.horizontal,
        spacing: AppSpacing.md,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            QuickActionButton(
              icon: Icons.category,
              label: "Categories",
              onTap: () => context.go("/categories")
            ),
            QuickActionButton(
              icon: Icons.add,
              label: "Transaction",
              onTap: () => TransactionModal.show(context, null, null)
            ),
        ],
      )
    );
  }
}