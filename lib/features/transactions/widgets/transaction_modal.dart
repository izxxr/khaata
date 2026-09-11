import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/app/bloc/app_bloc.dart';
import 'package:khaata/common/khaata_colors.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/features/accounts/widgets/accounts_dropdown.dart';
import 'package:khaata/features/transactions/services/counterparty_repository.dart';
import 'package:khaata/features/transactions/widgets/counterparty_modal.dart';
import 'package:khaata/widgets/confirm_dialog.dart';
import 'package:khaata/widgets/datetime_picker.dart';
import 'package:khaata/features/transactions/services/category_repository.dart';
import 'package:khaata/features/transactions/services/transaction_repository.dart';
import 'package:khaata/features/transactions/widgets/category_modal.dart';
import 'package:khaata/widgets/dropdown_with_action.dart';

class TransactionModal extends StatefulWidget {
  const new({super.key, this.transaction, required this.accountId});

  final Transaction? transaction;
  final int? accountId;

  static Future show(
    BuildContext context,
    int? accountId,
    Transaction? transaction,
  ) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return TransactionModal(
          accountId: accountId,
          transaction: transaction,
        );
      },
    );
  }

  @override
  State<TransactionModal> createState() => _TransactionModalState();
}


class _TransactionModalState extends State<TransactionModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountFocusNode = FocusNode();

  String title = "";
  String description = "";
  DateTime createdAt = DateTime.now();
  int amount = 0;
  int sign = 1;
  int? accountId;
  int? categoryId;
  int? counterpartyId;

  late TextEditingController datetimeController;

  int _parseAmount(String raw, int sign) {
    final parts = raw.split('.');

    final whole = int.parse(parts[0]);
    final frac = parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0'));

    return sign * (whole * 100 + frac);
  }

  @override
  void initState() {
    super.initState();

    title = widget.transaction?.title ?? "";
    description = widget.transaction?.description ?? "";
    createdAt = widget.transaction?.createdAt ?? DateTime.now();
    amount = widget.transaction?.amount ?? 0;
    sign = amount >= 0 ? 1 : -1;
    accountId = widget.accountId ?? context.read<AppBloc>().state.defaultAccountId;
    categoryId = widget.transaction?.categoryId;
    counterpartyId = widget.transaction?.counterpartyId;
    datetimeController = TextEditingController(
      text: context.read<AppBloc>().state.formatDateTime(createdAt)
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.globalPadding),
        child: Form(
          key: _formKey,
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
                        "${widget.transaction != null ? 'Modify' : 'Log'} Transaction",
                        style: Theme.of(context).textTheme.titleMedium
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        "${widget.transaction != null ? 'Edit' : 'Enter'} the transaction details",
                        style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Theme.of(context).hintColor)
                      ),
                    ],
                  ),
                  Spacer(),
                  (widget.transaction != null) ?
                    IconButton(
                      onPressed: () async {
                        final confirmed = await showConfirmDialog(
                          context, 
                          title: 'Delete Transaction', 
                          message: 'Are you sure? This action is irreversible.'
                        );

                        if (!confirmed || !context.mounted) return;

                        await context.read<TransactionRepository>().deleteTransaction(widget.transaction!.id);

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
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      _formKey.currentState!.save();

                      if (accountId == null) return;

                      if (widget.transaction != null) {
                        await context.read<TransactionRepository>().updateTransaction(
                          widget.transaction!.id,
                          title: title,
                          description: description,
                          amount: amount,
                          createdAt: createdAt,
                          categoryId: drift.Value(categoryId),
                          counterpartyId: drift.Value(counterpartyId),
                        );
                      } else {
                        await context.read<TransactionRepository>().createTransaction(
                          accountId!,
                          title,
                          amount,
                          description: description,
                          createdAt: createdAt,
                          categoryId: categoryId,
                          counterpartyId: counterpartyId,
                        );
                      }

                      _formKey.currentState!.reset();

                      if (!context.mounted) return;

                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.done),
                    style: IconButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primaryContainer),
                  )
                ],
              ),
              SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  IconButton(
                    icon: Icon(sign == 1 ? Icons.add : Icons.remove),
                    color: sign == 1 ? Colors.green : Colors.red,
                    onPressed: () {
                      setState(() {
                        sign = -sign;
                        _amountFocusNode.requestFocus();
                      });
                    },
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        hint: Text(
                          "Amount...",
                          style: TextStyle(
                            fontSize: 22,
                            color: Theme.of(context).hintColor
                          )
                        ),
                        suffixIcon: Icon(Icons.money),
                        border: UnderlineInputBorder(),
                      ),
                      style: TextStyle(
                        color: sign == 1 ? Colors.green : Colors.red,
                        fontSize: 22
                      ),
                      autofocus: true,
                      focusNode: _amountFocusNode,
                      textInputAction: TextInputAction.next,
                      initialValue: widget.transaction != null ? (widget.transaction!.amount / 100).abs().toString() : "",
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
              SizedBox(height: AppSpacing.lg),
              widget.accountId == null ?
                AccountsDropdown(
                  accountId: accountId,
                  onChanged: (newValue) {
                    accountId = newValue;
                  },
                  onSaved: (newValue) {
                    accountId = newValue;
                  }
                )
              : SizedBox(),
              SizedBox(height: AppSpacing.md),
              TextFormField(
                decoration: InputDecoration(
                  label: Text("Title"),
                  hint: Text("Food, groceries, salary, etc."),
                ),
                initialValue: widget.transaction?.title,
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
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: AppSpacing.md),
              TextFormField(
                decoration: InputDecoration(
                  label: Text("Description (optional)"),
                ),
                initialValue: widget.transaction?.description,
                onSaved: (newValue) {
                  description = newValue ?? '';
                },
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: datetimeController,
                readOnly: true,
                onTap: () async {
                  createdAt = await showDateTimePickerModal(
                    context,
                    initialDateTime: createdAt
                  ) ?? DateTime.now();

                  if (!context.mounted) return;

                  datetimeController.value = TextEditingValue(
                    text: context.read<AppBloc>().state.formatDateTime(createdAt)
                  );
                },
                decoration: const InputDecoration(
                  labelText: 'Time',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: AppSpacing.md),
              DropdownWithAction<Category, int>(
                stream: context.read<CategoryRepository>().watchCategories(),
                itemBuilder: (c) => DropdownMenuItem<int>(
                  value: c.id,
                  child: Row(
                    children: [
                      Icon(
                        Icons.category,
                        color: KhaataColors.fromId(c.color).color
                      ),
                      SizedBox(width: AppSpacing.md), // Gives space between icon and text
                      Text(c.name),
                    ],
                  ),
                ),
                labelText: "Category",
                newItemValue: -1,
                noSelectionValue: null,
                initialSelection: categoryId,
                onNewItem: () async {
                  final newId = await CategoryModal.show(context, null);
                  
                  setState(() {
                    categoryId = newId;
                  });

                  return newId;
                },
                onChanged: (newValue) {
                  categoryId = newValue;
                },
              ),
              SizedBox(height: AppSpacing.md),
              DropdownWithAction<Counterparty, int>(
                stream: context.read<CounterpartyRepository>().watchCounterparties(),
                itemBuilder: (c) => DropdownMenuItem<int>(
                  value: c.id,
                  child: Row(
                    children: [
                      Icon(Icons.people),
                      SizedBox(width: AppSpacing.md), // Gives space between icon and text
                      Text(c.name),
                    ],
                  ),
                ),
                labelText: sign == -1 ? "Payee" : "Payer",
                newItemValue: -1,
                noSelectionValue: null,
                initialSelection: counterpartyId,
                onNewItem: () async {
                  final newId = await CounterpartyModal.show(context, null);
                  
                  setState(() {
                    counterpartyId = newId;
                  });

                  return newId;
                },
                onChanged: (newValue) {
                  counterpartyId = newValue;
                },
              ),
            ],
          )
        )
      )
    );
  }
}
