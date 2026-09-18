import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/features/accounts/widgets/accounts_dropdown.dart';
import 'package:khaata/features/transactions/widgets/amount_entry.dart';
import 'package:khaata/features/transactions/services/transaction_repository.dart';

class TransferModal extends StatefulWidget {
  const new({
    super.key,
    required this.sourceAccount,
  });

  final Account? sourceAccount;

  static Future show(
    BuildContext context,
    Account? sourceAccount,
  ) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return TransferModal(sourceAccount: sourceAccount);
      },
    );
  }

  @override
  State<TransferModal> createState() => _TransferModalState();
}


class _TransferModalState extends State<TransferModal> {
  int amount = 0;
  Account? sourceAccount;
  Account? destinationAccount;

  @override
  void initState() {
    super.initState();

    sourceAccount = widget.sourceAccount;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.globalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Transfer",
                      style: Theme.of(context).textTheme.titleMedium
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      "Send money from this account to another",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).hintColor
                      )
                    ),
                  ],
                ),
                Spacer(),
                IconButton(
                  onPressed: () async {
                    if (sourceAccount == null || destinationAccount == null) return;

                    final repo = context.read<TransactionRepository>();
                    final sourceTransactionId = await repo.createTransaction(
                      sourceAccount!.id,
                      -amount,
                      title: "Transfer to ${destinationAccount!.title}",
                      createdAt: DateTime.now(),
                    );

                    if (!context.mounted) return;

                    final destinationTransactionId = await repo.createTransaction(
                      destinationAccount!.id,
                      amount,
                      title: "Received from ${destinationAccount!.title}",
                      createdAt: DateTime.now(),
                      associatedTransactionId: sourceTransactionId,
                    );

                    if (!context.mounted) return;

                    await repo.updateTransaction(
                      sourceTransactionId,
                      associatedTransactionId: drift.Value(destinationTransactionId)
                    );

                    if (!context.mounted) return;

                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.done),
                  style: IconButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primaryContainer),
                )
              ],
            ),
            SizedBox(height: AppSpacing.xl),
            AmountEntry(
              onChanged: (newValue) {
                if (newValue == null) return;

                amount = newValue;
              },
              positiveOnly: true,
            ),
            SizedBox(height: AppSpacing.xl),
            AccountsDropdown(
              accountId: destinationAccount?.id,
              labelText: "Destination",
              exclude: [sourceAccount!.id],
              onChanged: (newValue) {
                destinationAccount = newValue;
              },
              onSaved: (newValue) {
                destinationAccount = newValue;
              }
            )
          ],
        )
      )
    );
  }
}
