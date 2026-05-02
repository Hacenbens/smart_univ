import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/features/settings/presentation/bloc/settings_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const _languages = [
    ('en', 'English'),
    ('fr', 'Français'),
    ('ar', 'العربية'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) => ListView(
          children: [
            _SectionHeader('Appearance'),
            _ThemeTile(themeMode: state.themeMode),
            const Divider(height: 1),
            _SectionHeader('Language'),
            _LanguageTile(
              selectedCode: state.language,
              languages: _languages,
            ),
            const Divider(height: 1),
            _SectionHeader('Notifications'),
            SwitchListTile(
              title: const Text('Push notifications'),
              subtitle: const Text('Announcements and event reminders'),
              value: state.notificationsEnabled,
              onChanged: (enabled) => context
                  .read<SettingsBloc>()
                  .add(SettingsNotificationsChanged(enabled)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: tt.labelSmall?.copyWith(
          color: cs.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final ThemeMode themeMode;
  const _ThemeTile({required this.themeMode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.palette_outlined),
          const SizedBox(width: 16),
          const Expanded(child: Text('Theme')),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto_outlined, size: 18),
                label: Text('Auto'),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode_outlined, size: 18),
                label: Text('Light'),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode_outlined, size: 18),
                label: Text('Dark'),
              ),
            ],
            selected: {themeMode},
            onSelectionChanged: (selected) => context
                .read<SettingsBloc>()
                .add(SettingsThemeChanged(selected.first)),
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String selectedCode;
  final List<(String, String)> languages;

  const _LanguageTile({
    required this.selectedCode,
    required this.languages,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.language_outlined),
      title: const Text('Language'),
      trailing: DropdownButton<String>(
        value: selectedCode,
        underline: const SizedBox.shrink(),
        items: languages
            .map((l) => DropdownMenuItem(value: l.$1, child: Text(l.$2)))
            .toList(),
        onChanged: (code) {
          if (code != null) {
            context
                .read<SettingsBloc>()
                .add(SettingsLanguageChanged(code));
          }
        },
      ),
    );
  }
}
