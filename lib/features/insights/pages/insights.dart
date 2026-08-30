import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/common/khaata_colors.dart';
import 'package:khaata/features/accounts/services/account_repository.dart';
import 'package:khaata/features/accounts/widgets/account_overview_card.dart';
import 'package:khaata/features/insights/widgets/filters_modal.dart';
import 'package:khaata/features/insights/widgets/transactions_summary_list.dart';
import 'package:khaata/features/transactions/services/category_repository.dart';
import 'package:khaata/features/transactions/services/counterparty_repository.dart';


class Insights extends StatefulWidget {
  const new({super.key});

  @override
  State<Insights> createState() => _InsightsState();
}

class _InsightsState extends State<Insights> {
  Filters? filter;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<AccountRepository>().watchAccounts(),
      builder: (context, snapshot) {
        if (snapshot.data == null || snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        filter = filter ?? Filters.getDefault(snapshot.data!);

        final accountIds = filter!.accounts.map((a) => a.id).toList();

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await FiltersModal.show(
                context,
                snapshot.data!,
                filter!,
              );

              if (result == null) return;

              setState(() {
                filter = result;
              });
            },
            child: Icon(Icons.filter_alt)
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.globalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Insights",
                    style: Theme.of(context).textTheme.titleLarge
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    "Visualize your finances with detailed insights",
                    style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(color: Theme.of(context).hintColor),
                  ),
                  SizedBox(height: AppSpacing.xl),
                  AccountOverviewCard(accountIds: accountIds),
                  SizedBox(height: AppSpacing.xl),
                  Text("Top Categories", style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: AppSpacing.md),
                  TransactionsSummaryList(
                    stream: context.read<CategoryRepository>().watchTopCategories(accountIds),
                    nameBuilder: (c) => Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: 18,
                          color: KhaataColors.fromId(c.color).color
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            c.name,
                            overflow: TextOverflow.ellipsis,
                          )
                        ),
                      ]
                    )
                  ),
                  SizedBox(height: AppSpacing.xl),
                  Text("Top Counterparties", style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: AppSpacing.md),
                  TransactionsSummaryList(
                    stream: context.read<CounterpartyRepository>().watchTopCounterparties(accountIds),
                    nameBuilder: (c) => Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 18,
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            c.name,
                            overflow: TextOverflow.ellipsis,
                          )
                        ),
                      ]
                    )
                  )
                ],
              )
            )
          )
        );
      }
    );
  }
}
