import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:intl/intl.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/database/database.dart';


class Filters {
  const new({
    required this.accounts,
    this.before,
    this.after,
  });

  final Set<Account> accounts;
  final DateTime? before;
  final DateTime? after;

  static Filters getDefault(List<Account> accounts) {
    final selectedAccounts = accounts.toSet();
    selectedAccounts.removeWhere((a) => a.isolatedAccount);

    return Filters(accounts: selectedAccounts);
  }

  static String? getRangeLabel(DateTime? before, DateTime? after) {
    if (before == null && after == null) return null;

    final formatter = DateFormat("dd/MM/yyyy");

    final beforeLabel = formatter.format(before ?? DateTime.now());
    final afterLabel = formatter.format(after ?? DateTime.now());

    return "$afterLabel - $beforeLabel";
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
  late DateTime? before;
  late DateTime? after;

  @override
  void initState() {
    super.initState();

    selectedAccounts = widget.filter.accounts;
    before = widget.filter.before;
    after = widget.filter.after;
  }

  @override
  Widget build(BuildContext context) {
    final rangeLabel = Filters.getRangeLabel(before, after);

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
                    Navigator.pop(
                      context,
                      Filters(
                        accounts: selectedAccounts,
                        before: before,
                        after: after,
                      )
                    );
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
            SizedBox(height: AppSpacing.md),
            DropdownMenu(
              width: double.infinity,
              label: Text(rangeLabel ?? "Date range"),
              dropdownMenuEntries: [
                DropdownMenuEntry(value: 0, label: "This month"),
                DropdownMenuEntry(value: 1, label: "This week"),
                DropdownMenuEntry(value: 2, label: "Today"),
                DropdownMenuEntry(value: 3, label: "Last 30 days"),
                DropdownMenuEntry(value: 4, label: "Last 7 days"),
                DropdownMenuEntry(value: 5, label: "Last 24 hours"),
                DropdownMenuEntry(value: 6, label: "Custom...", style: ElevatedButton.styleFrom(foregroundColor: Colors.blue)),
              ],
              onSelected: (value) async {
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);

                DateTime? newBefore;
                DateTime? newAfter;

                if (value == 0) {
                  newAfter  = today.copyWith(day: 1);
                } else if (value == 1) {
                  newAfter = today.subtract(Duration(days: now.weekday - 1));
                } else if (value == 2) {
                  newAfter = today;
                } else if (value == 3) {
                  newAfter = today.subtract(Duration(days: 30));
                } else if (value == 4) {
                  newAfter = today.subtract(Duration(days: 7));
                } else if (value == 5) {
                  newAfter = today.subtract(Duration(hours: 24));
                } else {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (range == null) return;

                  newAfter = range.start;
                  newBefore = range.end;
                }

                setState(() {
                  before = newBefore;
                  after = newAfter;
                });
              },
            )
          ]
        )
      )
    );
  }
}
