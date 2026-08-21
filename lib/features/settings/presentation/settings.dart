import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/app/bloc/app_bloc.dart';
import 'package:khaata/app/bloc/app_event.dart';
import 'package:khaata/features/settings/presentation/settings_entry.dart';


/// Main widget for the "Settings" section.
class Settings extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.globalPadding),
      children: [
        Text(
          "Settings",
          style: Theme.of(context).textTheme.titleLarge
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          "Customize Khaata the way you like it",
          style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: Theme.of(context).hintColor),
        ),
        SizedBox(height: AppSpacing.xl),
        SettingsEntry(
          label: "Theme",
          description: "To use device's default theme, set to System",
          controlWidget: DropdownMenu(
            initialSelection: context.read<AppBloc>().state.themeMode.name,
            dropdownMenuEntries: [
              DropdownMenuEntry(value: "system", label: "System"),
              DropdownMenuEntry(value: "light", label: "Light"),
              DropdownMenuEntry(value: "dark", label: "Dark"),
            ],
            onSelected: (value) {
              context.read<AppBloc>().add(
                ThemeModeUpdated(
                  newThemeMode: switch (value) {
                    "light" => ThemeMode.light,
                    "dark" => ThemeMode.dark,
                    _ => ThemeMode.system,
                  }
                )
              );
            },
          )
        ),
        SettingsEntry(
          label: "Shared Preferences",
          description: "Reset application shared preferences. For debug purposes only.",
          controlWidget: ElevatedButton.icon(
            onPressed: () {
              context.read<AppBloc>().add(StateReset());
            },
            label: Text(
              "Clear",
              style: Theme.of(context)
                           .textTheme
                           .labelLarge
                          ?.copyWith(color: Theme.of(context).colorScheme.onErrorContainer)
            ),
            icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.onErrorContainer),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
          )
        ),
      ],
    );
  }
}
