import 'package:flutter/material.dart';
import 'package:khaata/app/style.dart';

class TransactionsSummaryList<T> extends StatelessWidget {
  const new({super.key, required this.stream, required this.nameBuilder});

  final Stream<List<(T, int, int)>> stream;
  final Widget Function(T) nameBuilder;

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
          stream: stream,
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
                  Expanded(child: nameBuilder(e.$1)),
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
                    Expanded(child: Text(
                      "Incoming",
                      style: Theme.of(context).textTheme.labelLarge,
                      textAlign: TextAlign.end,
                    )),
                    Expanded(child: Text(
                      "Outgoing",
                      style: Theme.of(context).textTheme.labelLarge,
                      textAlign: TextAlign.end,
                    ))
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
