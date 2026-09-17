import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:intl/intl.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/features/accounts/services/account_repository.dart';
import 'package:khaata/features/transactions/services/category_repository.dart';
import 'package:khaata/features/transactions/services/counterparty_repository.dart';


class Filters {
  const new({
    required this.accounts,
    this.categories,
    this.counterparties,
    this.before,
    this.after,
  });

  final DateTime? before;
  final DateTime? after;
  final Set<Account> accounts;
  final Set<Category>? categories;
  final Set<Counterparty>? counterparties;

  static Filters getDefault(
    List<Account> accounts,
    {
      List<Category>? categories,
      List<Counterparty>? counterparties,
    }
  ) {
    final selectedAccounts = accounts.toSet();
    selectedAccounts.removeWhere((a) => a.isolatedAccount);

    return Filters(
      accounts: selectedAccounts,
      categories: categories?.toSet() ?? {},
      counterparties: counterparties?.toSet() ?? {},
    );
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
  const new({
    super.key,
    required this.filter,
    required this.accounts,
    this.categories,
    this.counterparties,
  });

  final Filters filter;
  final List<Account> accounts;
  final List<Category>? categories;
  final List<Counterparty>? counterparties;

  static Future<Filters?> show(
    BuildContext context,
    Filters? existingFilter,
    {
      List<Account>? accounts,
      bool additional = false
    }
  ) async {
    accounts = accounts ?? await context.read<AccountRepository>().watchAccounts().first;

    if (!context.mounted) return null;

    List<Category>? categories;
    List<Counterparty>? counterparties;

    if (additional) {
      categories = await context.read<CategoryRepository>().watchCategories().first;

      if (!context.mounted) return null;

      counterparties = await context.read<CounterpartyRepository>().watchCounterparties().first;
    }

    if (!context.mounted) return null;

    return await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return FiltersModal(
          filter: existingFilter ?? Filters.getDefault(
            accounts!,
            categories: categories,
            counterparties: counterparties
          ),
          accounts: accounts!,
          categories: categories,
          counterparties: counterparties,
        );
      },
    );
  }

  @override
  State<FiltersModal> createState() => _FiltersModalState();
}


class _FiltersModalState extends State<FiltersModal> {
  late Set<Account> selectedAccounts;
  late Set<Category>? selectedCategories;
  late Set<Counterparty>? selectedCounterparties;
  late DateTime? before;
  late DateTime? after;
  late bool additional = false;

  @override
  void initState() {
    super.initState();

    selectedAccounts = widget.filter.accounts;
    selectedCategories = widget.filter.categories;
    selectedCounterparties = widget.filter.counterparties;
    before = widget.filter.before;
    after = widget.filter.after;
    additional = widget.categories != null;
  }

  @override
  Widget build(BuildContext context) {
    final rangeLabel = Filters.getRangeLabel(before, after);

    List<Widget> additionalWidgets = [];

    if (additional) {
      additionalWidgets.addAll([
        FlutterMultiSelectDropdown(
          items: widget.categories!,
          selected: selectedCategories ?? widget.categories!.toSet(),
          width: double.infinity,
          searchable: true,
          trailing: Icon(Icons.category),
          itemLeadingBuilder: (item) => SizedBox(width: AppSpacing.sm),
          onChanged: (v) {
            setState(() {
              selectedCategories = v;
            });
          },
          labelBuilder: (v) {
            if (v.length == widget.categories!.length) return "All categories selected";

            if (v.length == 1) return "1 category selected";

            return "${v.length} categories selected";
          },
          label: (item) => item.name,
        ),
        SizedBox(height: AppSpacing.md),
        FlutterMultiSelectDropdown(
          items: widget.counterparties!,
          selected: selectedCounterparties ?? widget.counterparties!.toSet(),
          width: double.infinity,
          searchable: true,
          itemLeadingBuilder: (item) => SizedBox(width: AppSpacing.sm),
          onChanged: (v) {
            setState(() {
              selectedCounterparties = v;
            });
          },
          trailing: Icon(Icons.people),
          labelBuilder: (v) {
            if (v.length == widget.counterparties!.length) return "All counterparties selected";

            if (v.length == 1) return "1 counterparty selected";

            return "${v.length} counterparties selected";
          },
          label: (item) => item.name,
        ),
        SizedBox(height: AppSpacing.md),
      ]);
    }

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
                    Navigator.pop(
                      context,
                      Filters.getDefault(
                        widget.accounts,
                        categories: widget.categories,
                        counterparties: widget.counterparties,
                      )
                    );

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
                        categories: selectedCategories,
                        counterparties: selectedCounterparties,
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
              trailing: Icon(Icons.account_balance),
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
            ...additionalWidgets,
            DropdownMenu(
              width: double.infinity,
              label: Text(rangeLabel ?? "Date range"),
              trailingIcon: Icon(Icons.date_range),
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
