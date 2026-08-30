import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/database/database.dart';


class Filters {
  const new({
    required this.accounts,
  });

  final Set<Account> accounts;

  static Filters getDefault(List<Account> accounts) {
    final selectedAccounts = accounts.toSet();
    selectedAccounts.removeWhere((a) => a.isolatedAccount);

    return Filters(accounts: selectedAccounts);
  }
}


class FiltersModal extends StatefulWidget {
  const new({super.key, required this.filter, required this.accounts});

  final Filters filter;
  final List<Account> accounts;

  static Future<Filters?> show(
    BuildContext context,
    List<Account> accounts,
    Filters existingFilter,
  ) async {
    return await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return FiltersModal(
          filter: existingFilter,
          accounts: accounts,
        );
      },
    );
  }

  @override
  State<FiltersModal> createState() => _FiltersModalState();
}


class _FiltersModalState extends State<FiltersModal> {
  late Set<Account> selectedAccounts;

  @override
  void initState() {
    super.initState();

    selectedAccounts = widget.filter.accounts;
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
                      "Filters",
                      style: Theme.of(context).textTheme.titleMedium
                    ),
                  ],
                ),
                Spacer(),
                IconButton(
                  onPressed: () async {
                    Navigator.pop(context, Filters.getDefault(widget.accounts));

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All filters have been cleared'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: Icon(Icons.clear_all),
                ),
                SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: () async {
                    Navigator.pop(context, Filters(accounts: selectedAccounts));
                  },
                  icon: Icon(Icons.done),
                  style: IconButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primaryContainer),
                )
              ],
            ),
            SizedBox(height: AppSpacing.xl),
            FlutterMultiSelectDropdown(
              items: widget.accounts,
              selected: selectedAccounts,
              width: double.infinity,
              itemLeadingBuilder: (item) => SizedBox(width: AppSpacing.sm),
              itemTrailingBuilder: (item) =>
                item.isolatedAccount ?
                  Row(children: [
                    SizedBox(width: AppSpacing.md),
                    Icon(Icons.money_off, color: Colors.orange)
                  ])
                : SizedBox(),
              onChanged: (v) {
                if (v.isEmpty) {
                  // don't allow empty selections
                  v = selectedAccounts;
                }

                setState(() {
                  selectedAccounts = v;
                });
              },
              labelBuilder: (v) {
                if (v.length == widget.accounts.length) return "All accounts selected";

                if (v.length == 1) return "1 account selected";

                return "${v.length} accounts selected";
              },
              label: (item) => item.title,
            ),
          ]
        )
      )
    );
  }
}
