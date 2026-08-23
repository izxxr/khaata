import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/bloc/app_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/features/transactions/widgets/transaction_modal.dart';

class TransactionCard extends StatelessWidget {
  new({super.key, required this.transaction});

  final Transaction transaction;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final description = transaction.description ?? "";
    Color color;

    if (Theme.brightnessOf(context) == Brightness.light) {
      color = transaction.amount > 0 ? TransactionColors.incomeLight : TransactionColors.expenseLight;
    } else {
      color = transaction.amount > 0 ? TransactionColors.incomeDark : TransactionColors.expenseDark;
    }

    return Container(
      margin: EdgeInsets.only(top: AppSpacing.sm),
      child: InkWell(
        onTap: () => showTransactionModal(
          context,
          _formKey,
          transaction.accountId,
          transaction.id,
          initialTitle: transaction.title,
          initialDescription: transaction.description,
          initialAmount: transaction.amount,
          initialCreatedAt: transaction.createdAt,
        ),
        child: Ink(
          padding: EdgeInsets.all(AppSpacing.md),
          // margin: EdgeInsets.only(top: AppSpacing.md),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5)
          ),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    transaction.title,
                    style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                // ?.copyWith(fontWeight: FontWeight.bold)
                  ),
                  Spacer(),
                  Text(
                    (transaction.amount / 100).toStringAsFixed(2),
                    style: Theme.of(context)
                                .textTheme
                                .titleMedium
                  ),
                ]
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                context.read<AppBloc>().state.formatDateTime(transaction.createdAt),
                style: Theme.of(context)
                              .textTheme
                              .bodySmall
                            ?.copyWith(color: Theme.of(context).hintColor)
              ),
              SizedBox(height: description.isNotEmpty ? AppSpacing.md : 0),
              description.isNotEmpty ?
                Text(
                  transaction.description!,
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