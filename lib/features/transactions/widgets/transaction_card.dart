import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khaata/app/bloc/app_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/features/accounts/services/account_repository.dart';
import 'package:khaata/features/accounts/widgets/account_colors.dart';
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
    this.accountName,
    this.accountColor,
    this.amountColor,
    this.description,
  });

  final String title;
  final String time;
  final String amount;
  final Color color;
  final GestureTapCallback onTap;
  final Color backgroundColor;
  final String? accountName;
  final Color? accountColor;
  final Color? amountColor;
  final String? description;

  static Widget fromTransaction(
    BuildContext context,
    Transaction transaction,
    {
      bool basic = false,
    }
  ) {
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
      onTap = () => showTransactionModal(
        context,
        GlobalKey<FormState>(),
        transaction.accountId,
        transaction,
      );
    }

    final amount = (transaction.amount / 100).toStringAsFixed(2);
    final description = basic ? null :transaction.description;
    final time = context.read<AppBloc>().state.formatDateTime(transaction.createdAt);

    if (basic) {
      return FutureBuilder(
        future: context.read<AccountRepository>().getAccount(transaction.accountId),
        builder: (context, snapshot) {
          return TransactionCard(
            title: transaction.title,
            time: time,
            amount: amount,
            description: description,
            color: color,
            onTap: onTap,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            accountName: snapshot.data != null ? snapshot.data!.title : "",
            amountColor: transaction.amount > 0 ? Colors.green.shade500 : Colors.redAccent,
            accountColor: (
              snapshot.data != null ?
                AccountColor.fromId(snapshot.data!.color)
              : AccountColor.slate
            ).color
          );
        }
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final descriptionString = description ?? "";
 
    return Container(
      margin: EdgeInsets.only(top: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(5),
            border: accountColor != null ?
              Border(
                left: BorderSide(
                  color: accountColor!,
                  width: 4
                )
              ) : null
          ),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                children: [
                  Text(
                    time,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor
                    )
                  ),
                  Spacer(),
                  Text(
                    accountName ?? "",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.underline,
                    )
                  ),
                ],
              ),
              SizedBox(height: descriptionString.isNotEmpty ? AppSpacing.md : 0),
              descriptionString.isNotEmpty ?
                Text(
                  descriptionString,
                  style: Theme.of(context).textTheme.bodySmall
                )
              : SizedBox()
            ]
          ),
        ),
      ),
    );
  }
}