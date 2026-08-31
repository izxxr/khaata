import 'package:flutter/material.dart';
import 'package:khaata/app/style.dart';

class TransactionsSummaryList<T> extends StatefulWidget {
  const new({
    super.key,
    required this.streamFunction,
    required this.accountIds,
    required this.nameBuilder,
    this.before,
    this.after,
  });

  final Stream<List<(T, int, int)>> Function(
    List<int>, {
      bool sortByIncome,
      DateTime? after,
      DateTime? before,
    }
  ) streamFunction;
  final List<int> accountIds;
  final Widget Function(T) nameBuilder;
  final DateTime? before;
  final DateTime? after;

  @override
  State<TransactionsSummaryList<T>> createState() => _TransactionsSummaryListState();
}


class _TransactionsSummaryListState<T> extends State<TransactionsSummaryList<T>> {
  bool sortedByIncome = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppSpacing.sm)
        ),
        constraints: BoxConstraints(
          maxHeight: 256,
        ),
        child: StreamBuilder(
          stream: widget.streamFunction(
            widget.accountIds,
            sortByIncome: sortedByIncome,
            before: widget.before,
            after: widget.after,
          ),
          builder: (context, snapshot) {
            if (snapshot.data == null || snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();              
            }

            final entries = snapshot.data!;

            if (entries.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text("No data available", style: Theme.of(context).textTheme.titleLarge),
                  ],
                )
              );
            }

            final rows = entries.map((e) =>
              Row(
                children: [
                  Expanded(child: widget.nameBuilder(e.$1)),
                  Expanded(child: Text(
                    (e.$2 / 100).toStringAsFixed(2),
                    style: TextStyle(color: Colors.green.shade500, fontWeight: .bold),
                    textAlign: TextAlign.end,
                  )),
                  Expanded(child: Text(
                    (e.$3 / 100).toStringAsFixed(2),
                    style: TextStyle(color: Colors.redAccent, fontWeight: .bold),
                    textAlign: TextAlign.end,
                  ))
                ],
              )
            );

            return SingleChildScrollView(child: Column(
              spacing: AppSpacing.md,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(
                      "",
                      style: Theme.of(context).textTheme.labelLarge,
                    )),
                    Expanded(child: GestureDetector(
                      onTap: () {
                        if (!sortedByIncome) setState(() { sortedByIncome = true; });
                      },
                      child: Text(
                        "Incoming",
                        style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      decoration: sortedByIncome ? .underline : null,
                                      color: sortedByIncome ?
                                              Theme.of(context).colorScheme.primary
                                            : null
                                    ),
                        textAlign: TextAlign.end,
                      )
                    )),
                    Expanded(child: GestureDetector(
                      onTap: () {
                        if (sortedByIncome) setState(() { sortedByIncome = false; });
                      },
                      child: Text(
                        "Outgoing",
                        style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      decoration: !sortedByIncome ? .underline : null,
                                      color: !sortedByIncome ?
                                              Theme.of(context).colorScheme.primary
                                            : null
                                    ),
                        textAlign: TextAlign.end,
                      )
                    )),
                  ],
                ),
                ...rows
              ],
            ));
          }
        )
      ),
    );
  }
}
