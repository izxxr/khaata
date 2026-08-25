import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khaata/app/bloc/app_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/common/khaata_colors.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/features/transactions/widgets/transaction_modal.dart';

class TransactionCard extends StatelessWidget {
  const new({
    super.key,
    required this.title,
    required this.time,
    required this.amount,
    required this.color,
    required this.onTap,
    required this.backgroundColor,
    this.account,
    this.amountColor,
    this.description,
    this.category,
  });

  final String title;
  final String time;
  final String amount;
  final Color color;
  final GestureTapCallback onTap;
  final Color backgroundColor;
  final Account? account;
  final Color? amountColor;
  final String? description;
  final Category? category;

  static Widget fromTransaction(
    BuildContext context,
    (Transaction, $$TransactionsTableReferences) transactionData,
    {
      bool basic = false,
    }
  ) {
    final (transaction, transactionRefs) = transactionData;

    GestureTapCallback onTap;
    Color color;

    if (Theme.brightnessOf(context) == Brightness.light) {
      color = transaction.amount > 0 ? TransactionColors.incomeLight : TransactionColors.expenseLight;
    } else {
      color = transaction.amount > 0 ? TransactionColors.incomeDark : TransactionColors.expenseDark;
    }

    if (basic) {
      onTap = () => context.go("/accounts/${transaction.accountId}");
    } else {
      onTap = () => TransactionModal.show(
        context,
        transaction.accountId,
        transaction,
      );
    }

    final amount = (transaction.amount / 100).toStringAsFixed(2);
    final description = transaction.description;
    final time = context.read<AppBloc>().state.formatDateTime(transaction.createdAt);

    if (basic) {
      return TransactionCard(
        title: transaction.title,
        time: time,
        amount: amount,
        description: description,
        color: color,
        onTap: onTap,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        amountColor: transaction.amount > 0 ? Colors.green.shade500 : Colors.redAccent,
        account: transactionRefs.accountId.prefetchedData?.first,
        category: transactionRefs.categoryId?.prefetchedData?.first,
      );
    }

    return TransactionCard(
      title: transaction.title,
      time: time,
      amount: amount,
      description: description,
      color: color,
      backgroundColor: color,
      onTap: onTap,
      category: transactionRefs.categoryId?.prefetchedData?.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> descriptionWidgets = [];
    List<Widget> accountWidgets = [];
    List<Widget> categoryWidgets = [];

    if ((description ?? "").isNotEmpty) {
      descriptionWidgets = [
        SizedBox(height: AppSpacing.sm + 4),
        Text(description!, style: Theme.of(context).textTheme.bodySmall)
      ];
    }

    if (account != null) {
      accountWidgets = [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.account_balance, size: 16, color: Theme.of(context).hintColor),
            SizedBox(width: AppSpacing.sm),
            Text(
              account?.title ?? "",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                // decoration: TextDecoration.underline,
                color: Theme.of(context).hintColor,
              )
            ),
          ],
        ),
      ];
    }

    if (category != null) {
      categoryWidgets = [
        Spacer(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.category,
              color: KhaataColors.fromId(category!.color).color,
              size: 16
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              category!.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).hintColor
              )
            ),
          ],
        ),
      ];
    }
 
    return Container(
      margin: EdgeInsets.only(top: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(5),
            border: account != null ?
              Border(
                left: BorderSide(
                  color: KhaataColors.fromId(account!.color).color,
                  width: 4
                )
              ) : null
          ),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Spacer(),
                  Text(
                    amount,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: amountColor)
                  ),
                ]
              ),
              SizedBox(height: AppSpacing.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    time,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor
                    )
                  ),
                  Spacer(),
                ],
              ),
              ...descriptionWidgets,
              (accountWidgets.length + categoryWidgets.length) > 0 ?
                SizedBox(height: AppSpacing.md)
              : SizedBox(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [...accountWidgets, ...categoryWidgets],
              ),
            ]
          ),
        ),
      ),
    );
  }
}