import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/app/bloc/app_bloc.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/features/transactions/services/transaction_repository.dart';
import 'package:khaata/widgets/confirm_dialog.dart';
import 'package:khaata/widgets/datetime_picker.dart';


int _parseAmount(String raw, int sign) {
  final parts = raw.split('.');

  final whole = int.parse(parts[0]);
  final frac = parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0'));

  return sign * (whole * 100 + frac);
}


Future showTransactionModal(
  BuildContext context,
  GlobalKey<FormState> formKey,
  int accountId,
  Transaction? transaction,
) async {
  String title = "";
  String description = "";
  DateTime createdAt = transaction?.createdAt ?? DateTime.now();
  int amount = 0;
  int sign = 1;

  final dateTimeController = TextEditingController(
    text: context.read<AppBloc>().state.formatDateTime(createdAt)
  );

  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.globalPadding),
          child: Form(
            key: formKey,
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
                          "${transaction != null ? 'Modify' : 'Log'} Transaction",
                          style: Theme.of(context).textTheme.titleMedium
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          "${transaction != null ? 'Edit' : 'Enter'} the transaction details",
                          style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Theme.of(context).hintColor)
                        ),
                      ],
                    ),
                    Spacer(),
                    (transaction != null) ?
                      IconButton(
                        onPressed: () async {
                          final confirmed = await showConfirmDialog(
                            context, 
                            title: 'Delete Transaction', 
                            message: 'Are you sure? This action is irreversible.'
                          );

                          if (!confirmed || !context.mounted) return;

                          await context.read<TransactionRepository>().deleteTransaction(transaction.id);

                          if (!context.mounted) return;

                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.delete),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.errorContainer,
                          foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      )
                    : SizedBox(),
                    SizedBox(width: AppSpacing.sm),
                    IconButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        formKey.currentState!.save();

                        if (transaction != null) {
                          await context.read<TransactionRepository>().updateTransaction(
                            transaction.id,
                            title: title,
                            description: description,
                            amount: amount,
                            createdAt: createdAt,
                          );
                        } else {
                          await context.read<TransactionRepository>().createTransaction(
                            accountId,
                            title,
                            amount,
                            description: description,
                            createdAt: createdAt,
                          );
                        }

                        formKey.currentState!.reset();

                        if (!context.mounted) return;

                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.done),
                      style: IconButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primaryContainer),
                    )
                  ],
                ),
                SizedBox(height: AppSpacing.xl),
                TextFormField(
                  decoration: InputDecoration(
                    label: Text("Title"),
                    hint: Text("Food, groceries, salary, etc."),
                  ),
                  initialValue: transaction?.title,
                  validator: (value) {
                    if (value == null) {
                      return 'Transaction title is required.';
                    }

                    if (value.isEmpty) {
                      return 'Transaction title is required.';
                    }

                    if (value.length < 2) {
                      return 'Transaction title must be at least 2 characters.';
                    }

                    return null;
                  },
                  onSaved: (newValue) {
                    title = newValue ?? '';
                  },
                ),
                SizedBox(height: AppSpacing.md),
                TextFormField(
                  decoration: InputDecoration(
                    label: Text("Description (optional)"),
                  ),
                  initialValue: transaction?.description,
                  onSaved: (newValue) {
                    description = newValue ?? '';
                  },
                ),
                SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: dateTimeController,
                  readOnly: true,
                  onTap: () async {
                    createdAt = await showDateTimePickerModal(
                      context,
                      initialDateTime: createdAt
                    ) ?? DateTime.now();

                    if (!context.mounted) return;

                    dateTimeController.value = TextEditingValue(
                      text: context.read<AppBloc>().state.formatDateTime(createdAt)
                    );
                  },
                  decoration: const InputDecoration(
                    labelText: 'Time',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: DropdownButtonFormField(
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            value: 1,
                            alignment: Alignment.center,
                            child: Text(
                              "+",
                              style: Theme.of(context)
                                           .textTheme
                                           .titleLarge
                                          ?.copyWith(color: Colors.green),
                            ),
                          ),
                          DropdownMenuItem(
                            value: -1,
                            alignment: Alignment.center,
                            child: Text(
                              "-",
                              style: Theme.of(context)
                                           .textTheme
                                           .titleLarge
                                          ?.copyWith(color: Colors.red),
                            ),
                          ),
                        ],
                        initialValue: transaction != null ? (transaction.amount > 0 ? 1 : -1) : 1,
                        onChanged: (value) {
                          sign = value ?? 1;
                        },
                        onSaved: (newValue) {
                          sign = newValue ?? 1;
                        },
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: TextFormField(
                        decoration: InputDecoration(
                          label: Text("Amount"),
                          hint: Text("Currency e.g. 43.10 or 43"),
                          suffixIcon: Icon(Icons.money)
                        ),
                        initialValue: transaction != null ? (transaction.amount / 100).abs().toString() : "",
                        keyboardType: TextInputType.number, // Shows numeric keyboard
                        inputFormatters: <TextInputFormatter>[
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final value = newValue.text;

                            if (value.isEmpty) {
                              return newValue;
                            }

                            if (RegExp(r'^\d+(?:\.\d{0,2})?$').hasMatch(value)) {
                              return newValue;
                            }

                            return oldValue;
                          })
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter an amount';
                          }

                          if (!RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(value)) {
                            return 'Invalid amount';
                          }

                          if (_parseAmount(value, sign) == 0) {
                            return 'Amount cannot be zero';
                          }

                          return null;
                        },
                        onSaved: (newValue) {
                          if (newValue == null || newValue.isEmpty) return;

                          amount = _parseAmount(newValue, sign);
                        },
                      )
                    ),
                  ],
                ),
              ],
            )
          )
        )
      );
    },
  );
}
