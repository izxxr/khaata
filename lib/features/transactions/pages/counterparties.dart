import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/features/transactions/services/counterparty_repository.dart';
import 'package:khaata/features/transactions/widgets/counterparty_modal.dart';
import 'package:khaata/widgets/default_screen.dart';

class Counterparties extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Counterparties"),
        actions: [
          IconButton(
            onPressed: () => CounterpartyModal.show(context, null),
            icon: Icon(Icons.add)
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(AppSpacing.globalPadding),
        child: StreamBuilder(
          stream: context.read<CounterpartyRepository>().watchCounterparties(),
          builder: (builder, snapshot) {
            if (snapshot.data == null || snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            final counterparties = snapshot.data!;

            if (counterparties.isEmpty) {
              return DefaultScreen(
                icon: Icons.people,
                title: "No counterparties",
                subtitle: "Tap on + to create one"
              );
            }

            return ListView.builder(
              itemCount: counterparties.length,
              itemBuilder: (context, index) {
                final party = counterparties[index];

                return ListTile(
                  title: Text(party.name),
                  horizontalTitleGap: AppSpacing.lg,
                  subtitle: (party.description ?? "").isNotEmpty ? Text(party.description!) : null,
                  visualDensity: VisualDensity.comfortable,
                  leading: Icon(Icons.people),
                  onTap: () => CounterpartyModal.show(context, party),
                );
              }
            );
          }
        ),
      )
    );
  }
}