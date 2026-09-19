import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/common/formatters.dart';
import 'package:khaata/common/helpers.dart';
import 'package:khaata/features/transactions/services/transaction_repository.dart';

class ReconcileModal extends StatefulWidget {
  const new({super.key, required this.accountId, required this.balance});

  final int accountId;
  final int balance;

  /// Shows the reconcile modal.
  /// 
  /// Returns the ID of transaction that reconciled balance. If reconcilation
  /// wasn't done (user canceled), null is returned.
  static Future<int?> show(BuildContext context, int accountId, int balance) async {
    final result = await showDialog<int?>(
      context: context,
      barrierDismissible: true,
      builder: (context) => ReconcileModal(accountId: accountId, balance: balance),
    );

    return result; // Returns false if user taps outside
  }

  @override
  State<ReconcileModal> createState() => _ReconcileModalState();
}

class _ReconcileModalState extends State<ReconcileModal> {
  final _balanceController = TextEditingController();
  final _differenceController = TextEditingController();

  int _differenceValue = 0;

  @override
  Widget build(BuildContext context) {
    Color? color;

    if (_differenceValue > 0) {
      color = Colors.green.shade500;
    } else if (_differenceValue < 0) {
      color = Colors.redAccent;
    }

    return AlertDialog(
      title: Text("Reconcile"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Sync current balance with actual balance"),
          SizedBox(height: AppSpacing.xl),
          TextField(
            readOnly: true,
            controller: TextEditingController(text: parseTransactionAmount(widget.balance)),
            decoration: InputDecoration(
              label: Text("Current Balance"),
              suffixIcon: Icon(Icons.account_balance),
              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width * 0.7)
            ),
          ),
          SizedBox(height: AppSpacing.md),
          TextField(
            autofocus: true,
            controller: _balanceController,
            decoration: InputDecoration(
              label: Text("Actual Balance"),
              suffixIcon: Icon(Icons.account_balance_wallet),
              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width * 0.7)
            ),
            inputFormatters: [getAmountFormatter()],
            onChanged: (value) {
              final actualBalance = parseRawAmount(value, 1) ?? widget.balance;

              setState(() {
                _differenceValue = actualBalance - widget.balance;
                _differenceController.value = TextEditingValue(text: parseTransactionAmount(_differenceValue, explicitSign: true));
              });
            },
          ),
          SizedBox(height: AppSpacing.md),
          TextFormField(
            readOnly: true,
            controller: _differenceController,
            decoration: InputDecoration(
              label: Text("Difference"),
              suffixIcon: Icon(Icons.difference, color: color),
              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width * 0.7)
            ),
            style: TextStyle(color: color),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel')
        ),
        ElevatedButton(
          onPressed: _differenceValue == 0 ? null : () async {
            if (_differenceValue == 0) return;

            final reconcileId = await context.read<TransactionRepository>().createTransaction(
              widget.accountId,
              _differenceValue,
              title: "Reconcile balance with source",
              createdAt: DateTime.now(),
            );

            if (!context.mounted) return;

            Navigator.pop(context, reconcileId);
          },
          child: Text("Reconcile"),
        ),
      ],
    );
  }
}