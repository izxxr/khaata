import 'package:flutter/material.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/features/accounts/widgets/account_colors.dart';

void showAccountCreationModal(
  BuildContext context,
  {
    required TextEditingController nameController,
    required TextEditingController descriptionController,
    required TextEditingController colorController,
    required VoidCallback onSubmit,
    bool isUpdate = false
  }
) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return SizedBox(
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
                        isUpdate ? "Update Account" : "Create Account",
                        style: Theme.of(context).textTheme.titleMedium
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        "${isUpdate ? 'Modify' : 'Enter'} the account details",
                        style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Theme.of(context).hintColor)
                      ),
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: onSubmit,
                    icon: Icon(Icons.done),
                    style: IconButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primaryContainer),
                  )
                ],
              ),
              SizedBox(height: AppSpacing.xl),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  label: Text("Account name"),
                  hint: Text("Bank, cash, wallet, etc."),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  label: Text("Description (optional)"),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              DropdownMenu<int>(
                label: Text("Color"),
                initialSelection: 0,
                menuHeight: 300,
                width: MediaQuery.of(context).size.width,
                controller: colorController,
                dropdownMenuEntries: [
                  for (var entry in AccountColor.values)
                    DropdownMenuEntry(
                      label: entry.name,
                      value: entry.id,
                      leadingIcon: Icon(Icons.circle, color: entry.color),
                    )
                ]
              ),
              SizedBox(height: AppSpacing.lg),
            ],
          )
        )
      );
    },
  );
}
