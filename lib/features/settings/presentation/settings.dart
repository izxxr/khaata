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
      ],
    );
  }
}
