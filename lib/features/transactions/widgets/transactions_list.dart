import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/widgets/default_screen.dart';
import 'package:khaata/features/transactions/services/transaction_repository.dart';
import 'package:khaata/features/transactions/widgets/transaction_card.dart';

class TransactionsList extends StatelessWidget {
  const new({super.key, this.account, this.limit});

  final Account? account;
  final int? limit;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<TransactionRepository>().watchTransactions(
        account?.id,
        limit,
        fetchCategory: true,
        fetchAccount: account == null,
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
            title: "No transactions yet",
            subtitle: account != null ? "Tap on + to log transactions" : "Log transactions from accounts page"
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: transactions.length,
          itemBuilder: (context, index) => Material(
            child: TransactionCard.fromTransaction(
              context,
              transactions[index],
              basic: account == null
            )
          )
        );
      }
    );
  }
}