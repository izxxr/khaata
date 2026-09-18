import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/app/bloc/app_bloc.dart';
import 'package:khaata/common/khaata_colors.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/features/accounts/widgets/accounts_dropdown.dart';
import 'package:khaata/features/transactions/services/counterparty_repository.dart';
import 'package:khaata/features/transactions/widgets/amount_entry.dart';
import 'package:khaata/features/transactions/widgets/counterparty_modal.dart';
import 'package:khaata/features/transactions/services/category_repository.dart';
import 'package:khaata/features/transactions/services/transaction_repository.dart';
import 'package:khaata/features/transactions/widgets/category_modal.dart';
import 'package:khaata/widgets/dropdown_with_action.dart';
import 'package:khaata/widgets/datetime_picker.dart';

class TransactionModal extends StatefulWidget {
  const new({
    super.key,
    required this.accountId,
    this.transaction,
    this.showAccountDropdown = false,
    this.isNew = false,
  });

  final Transaction? transaction;
  final int? accountId;
  final bool showAccountDropdown;
  final bool isNew;

  static Future show(
    BuildContext context,
    int? accountId,
    Transaction? transaction,
    {
      bool showAccountDropdown = false,
      bool isNew = false
    }
  ) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      useSafeArea: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return TransactionModal(
          accountId: accountId,
          transaction: transaction,
          showAccountDropdown: showAccountDropdown,
          isNew: isNew || transaction == null,
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
  final _timeFocusNode = FocusNode();
  final _accountDropdownKey = UniqueKey();

  UniqueKey _categoryDropdownKey = UniqueKey();

  String? title;
  String description = "";
  DateTime createdAt = DateTime.now();
  int amount = 0;
  int sign = 1;
  int? accountId;
  int? categoryId;
  int? counterpartyId;

  late TextEditingController datetimeController;

  @override
  void initState() {
    super.initState();

    title = widget.transaction?.title;
    description = widget.transaction?.description ?? "";
    amount = widget.transaction?.amount ?? 0;
    sign = amount >= 0 ? 1 : -1;
    accountId = widget.accountId ?? context.read<AppBloc>().state.defaultAccountId;
    categoryId = widget.transaction?.categoryId;
    counterpartyId = widget.transaction?.counterpartyId;

    if (widget.isNew) {
      createdAt = DateTime.now();
    } else {
      createdAt = widget.transaction?.createdAt ?? DateTime.now();
    }

    datetimeController = TextEditingController(
      text: context.read<AppBloc>().state.formatDateTime(createdAt)
    );
  }

  @override
  void dispose() {
    _timeFocusNode.dispose();
    _amountFocusNode.dispose();

    super.dispose();
  }

  void _updateTransaction(BuildContext context, Transaction transaction) async {
    final repo = context.read<TransactionRepository>();

    await repo.updateTransaction(
      transaction.id,
      title: title,
      description: description,
      amount: amount,
      createdAt: createdAt,
      categoryId: drift.Value(categoryId),
      counterpartyId: drift.Value(counterpartyId)
    );

    if (!context.mounted) return;

    if (transaction.associatedTransactionId != null) {
      await repo.updateTransaction(
        transaction.associatedTransactionId!,
        description: description,
        amount: -amount,
        createdAt: createdAt,
      );
    }
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
                        "${(widget.transaction != null && !widget.isNew) ? 'Modify' : 'Log'} Transaction",
                        style: Theme.of(context).textTheme.titleMedium
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        "${(widget.transaction != null && !widget.isNew) ? 'Edit' : 'Enter'} the transaction details",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).hintColor
                        )
                      ),
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      _formKey.currentState!.save();

                      if (accountId == null) return;

                      if (widget.transaction != null && !widget.isNew) {
                        _updateTransaction(context, widget.transaction!);
                      } else {
                        await context.read<TransactionRepository>().createTransaction(
                          accountId!,
                          amount,
                          title: title,
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
              AmountEntry(
                transaction: widget.transaction,
                onSaved: (newValue) {
                  if (newValue == null) return;

                  amount = newValue;
                },
              ),
              SizedBox(height: AppSpacing.lg),
              widget.showAccountDropdown ?
                AccountsDropdown(
                  key: _accountDropdownKey,
                  accountId: accountId,
                  onChanged: (newValue) {
                    accountId = newValue?.id;
                  },
                  onSaved: (newValue) {
                    accountId = newValue?.id;
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
                onSaved: (newValue) {
                  title = newValue;
                },
              ),
              SizedBox(height: AppSpacing.md),
              TextFormField(
                decoration: InputDecoration(
                  label: Text("Description (optional)"),
                ),
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: null,
                initialValue: widget.transaction?.description,
                onSaved: (newValue) {
                  description = newValue ?? '';
                },
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
              ),
              SizedBox(height: AppSpacing.md),
              DropdownWithAction<Counterparty, int>(
                stream: context.read<CounterpartyRepository>().watchCounterparties(),
                itemBuilder: (c) => DropdownMenuEntry<int>(
                  value: c.id,
                  label: c.name,
                  leadingIcon: Icon(Icons.people),
                ),
                labelText: sign == -1 ? "Payee" : "Payer",
                newItemValue: -1,
                noSelectionValue: -2,
                initialSelection: counterpartyId,
                onNewItem: () async {
                  final newId = await CounterpartyModal.show(context, null);
                  
                  setState(() {
                    counterpartyId = newId;
                  });

                  return newId;
                },
                onChanged: (newValue, data) {
                  if (newValue != null) {
                    try {
                      final cp = data.firstWhere((cp) => cp.id == newValue);

                      if (categoryId == null && cp.defaultCategoryId != null) {
                        categoryId = cp.defaultCategoryId;
                        _categoryDropdownKey = UniqueKey();
                      }
                    } catch (e) {
                      //
                    }
                  }

                  setState(() {
                    counterpartyId = newValue;
                  });
                },
              ),
              SizedBox(height: AppSpacing.md),
              DropdownWithAction<Category, int>(
                stream: context.read<CategoryRepository>().watchCategories(),
                key: _categoryDropdownKey,
                itemBuilder: (c) => DropdownMenuEntry<int>(
                  value: c.id,
                  label: c.name,
                  leadingIcon: Icon(
                    Icons.category,
                    color: KhaataColors.fromId(c.color).color
                  ),
                ),
                labelText: "Category",
                newItemValue: -1,
                noSelectionValue: -2,
                initialSelection: categoryId,
                onNewItem: () async {
                  final newId = await CategoryModal.show(context, null);
                  
                  setState(() {
                    categoryId = newId;
                  });

                  return newId;
                },
                onChanged: (newValue, _) {
                  categoryId = newValue;
                },
              ),
            ],
          )
        )
      )
    );
  }
}
