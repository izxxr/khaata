import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/app/bloc/app_bloc.dart';
import 'package:khaata/app/bloc/app_event.dart';
import 'package:khaata/features/settings/widgets/settings_entry.dart';


/// Main widget for the "Settings" section.
class Settings extends StatelessWidget {
  new({super.key});

  final Uri _viewSourceUrl = Uri.parse("https://github.com/izxxr/khaata");

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
          label: "Time Format",
          description: "24-hours: 14:29, 12-hours: 02:29 PM",
          controlWidget: DropdownMenu(
            initialSelection: context.read<AppBloc>().state.timeFormatIs24Hours ? 1 : 0,
            dropdownMenuEntries: [
              DropdownMenuEntry(value: 1, label: "24 hours"),
              DropdownMenuEntry(value: 0, label: "12 hours"),
            ],
            onSelected: (value) {
              context.read<AppBloc>().add(
                TimeFormatUpdated(is24HoursFormat: value == 1 ? true : false)
              );
            },
          )
        ),
        SettingsEntry(
          label: "Shared Preferences",
          description: "Reset application shared preferences.\n\nThis will clear app settings (username, theme, etc.) only. Accounts data and transactions remain unchanged.\n\nFor debugging purposes only.",
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
        SettingsEntry(
          label: "App Info",
          description: "Khaata version 2.0a1 - developed with ❤️ by Izhar Ahmad\n\n"
                       "This app is open source and welcomes contributions.\nView code and report issues on GitHub repository.",
          controlWidget: TextButton.icon(
            onPressed: () async {
              await launchUrl(_viewSourceUrl);
            },
            label: Text("View GitHub"),
            icon: Icon(Icons.link)
          ),
        )
      ],
    );
  }
}
