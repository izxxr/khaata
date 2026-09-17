import 'package:flutter/material.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/features/insights/widgets/filters_modal.dart';
import 'package:khaata/features/transactions/widgets/transactions_list.dart';

class TransactionsSearch extends StatefulWidget {
  const new({super.key});

  @override
  State<TransactionsSearch> createState() => _TransactionsSearchState();
}

class _TransactionsSearchState extends State<TransactionsSearch> {
  late String? _searchQuery;
  late Filters? _filter;

  @override
  void initState() {
    super.initState();

    _searchQuery = null;
    _filter = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await FiltersModal.show(context, _filter, additional: true);

              if (result == null) return;

              setState(() {
                _filter = result;
              });
            },
            icon: Icon(Icons.filter_alt)
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(AppSpacing.globalPadding),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hint: Text("Search..."),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            SizedBox(height: AppSpacing.lg),
            Expanded(
              child: TransactionsList(
                searchQuery: _searchQuery,
                accountIds: _filter?.accounts.map((e) => e.id).toList(),
                categoryIds: _filter?.categories?.map((e) => e.id).toList(),
                counterpartyIds: _filter?.counterparties?.map((e) => e.id).toList(),
                before: _filter?.before,
                after: _filter?.after,
                basic: true,
              )
            ),
          ],
        ),
      )
    );
  }
}