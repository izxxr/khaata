import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' as drift;
import 'package:khaata/app/style.dart';
import 'package:khaata/common/khaata_colors.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/features/transactions/services/category_repository.dart';
import 'package:khaata/features/transactions/services/counterparty_repository.dart';
import 'package:khaata/features/transactions/widgets/category_modal.dart';
import 'package:khaata/widgets/dropdown_with_action.dart';

class CounterpartyModal extends StatefulWidget {
  const new({super.key, this.counterparty});

  final Counterparty? counterparty;

  static Future<int?> show(BuildContext context, Counterparty? counterparty) async {
    final result = await showDialog<int?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CounterpartyModal(counterparty: counterparty),
    );
    return result; // Returns false if user taps outside
  }

  @override
  State<CounterpartyModal> createState() => _CounterpartyModalState();
}

class _CounterpartyModalState extends State<CounterpartyModal> {
  final _formKey = GlobalKey<FormState>();

  String? counterpartyName;
  String? counterpartyDescription;
  int? defaultCategoryId;

  @override
  void initState() {
    super.initState();

    defaultCategoryId = widget.counterparty?.defaultCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${widget.counterparty == null ? 'Create' : 'Edit'} counterparty...",
            style: Theme.of(context).textTheme.titleLarge
          ),
          Spacer(),
          widget.counterparty != null ?
            IconButton(
              onPressed: () async {
                await context.read<CounterpartyRepository>().deleteCounterparty(widget.counterparty!.id);

                if (!context.mounted) return;

                Navigator.pop(context, null);
              },
              icon: Icon(Icons.delete, size: 26, color: Colors.red.shade500)
            )
          : SizedBox()
        ]
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.md,
          children: [
            SizedBox(),
            TextFormField(
              onSaved: (v) {
                counterpartyName = v!.trim();
              },
              initialValue: widget.counterparty?.name,
              decoration: InputDecoration(
                label: Text("Name"),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return "Counterparty name is required";
                }
                return null;
              },
            ),
            TextFormField(
              onSaved: (v) {
                counterpartyDescription = v!.trim();
              },
              initialValue: widget.counterparty?.description,
              decoration: InputDecoration(
                label: Text("Description"),
              ),
            ),
            DropdownWithAction<Category, int>(
              stream: context.read<CategoryRepository>().watchCategories(),
              itemBuilder: (c) => DropdownMenuEntry<int>(
                value: c.id,
                label: c.name,
                leadingIcon: Icon(
                  Icons.category,
                  color: KhaataColors.fromId(c.color).color
                ),
              ),
              labelText: "Default Category",
              newItemValue: -1,
              noSelectionValue: -2,
              initialSelection: defaultCategoryId,
              onNewItem: () async {
                final newId = await CategoryModal.show(context, null);
                
                setState(() {
                  defaultCategoryId = newId;
                });

                return newId;
              },
              onChanged: (newValue, _) {
                defaultCategoryId = newValue;
              },
            )
          ]
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel')
        ),
        ElevatedButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            _formKey.currentState!.save();

            if (counterpartyName == null) {
              return;
            }

            int? counterpartyId = widget.counterparty?.id;

            if (counterpartyId == null) {
              counterpartyId = await context.read<CounterpartyRepository>().createCounterparty(
                counterpartyName!,
                description: counterpartyDescription,
                defaultCategoryId: defaultCategoryId,
              );
            } else {
              await context.read<CounterpartyRepository>().updateCounterparty(
                counterpartyId,
                name: counterpartyName,
                description: counterpartyDescription,
                defaultCategoryId: drift.Value(defaultCategoryId),
              );
            }

            if (!context.mounted) return;

            Navigator.pop(context, counterpartyId);
          },
          child: Text(widget.counterparty != null ? "Update" : "Create")
        ),
      ],
    );
  }
}
