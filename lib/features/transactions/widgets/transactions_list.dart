import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/widgets/default_screen.dart';
import 'package:khaata/features/transactions/services/transaction_repository.dart';
import 'package:khaata/features/transactions/widgets/transaction_card.dart';


class TransactionsList extends StatefulWidget {
  const new({
    super.key,
    this.infinite = true,
    this.basic = false,
    this.accountIds,
    this.categoryIds,
    this.counterpartyIds,
    this.before,
    this.after,
    this.searchQuery,
  });

  final bool infinite;
  final bool basic;
  final List<int>? accountIds;
  final List<int>? categoryIds;
  final List<int>? counterpartyIds;
  final DateTime? before;
  final DateTime? after;
  final String? searchQuery;

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}


class _TransactionsListState extends State<TransactionsList> {
  static const _pageSize = 7;

  final _scrollController = ScrollController();

  int _limit = _pageSize;

  @override
  void initState() {
    super.initState();

    if (widget.infinite) {
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    if (widget.infinite) {
      _scrollController.dispose();
    }

    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 200) {
      setState(() {
        _limit += _pageSize;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<TransactionRepository>().watchTransactions(
        widget.accountIds ?? [],
        limit: _limit,
        searchQuery: widget.searchQuery,
        categoryIds: widget.categoryIds,
        counterpartyIds: widget.counterpartyIds,
        before: widget.before,
        after: widget.after,
        fetchAccount: widget.basic,
        fetchCategory: true,
        fetchCounterparty: true,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final transactions = snapshot.data!;

        if (transactions.isEmpty) {
          return DefaultScreen(
            icon: Icons.info,
            title: "No transactions",
            subtitle: widget.accountIds != null ?
              "Tap on + to log transactions" :
              "Log transactions from accounts page"
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          controller: _scrollController,
          itemCount: transactions.length,
          itemBuilder: (context, index) => Material(
            child: TransactionCard.fromTransaction(
              context,
              transactions[index],
              basic: widget.basic,
            )
          )
        );
      }
    );
  }
}