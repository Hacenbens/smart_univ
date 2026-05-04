import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:smart_univ/features/auth/presentation/bloc/auth_bloc.dart';
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
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listenWhen: (prev, curr) =>
            curr.exportStatus == ExportStatus.failure &&
            prev.exportStatus != ExportStatus.failure,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.exportError ?? 'Export failed'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
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
            const Divider(height: 1),
            _SectionHeader('Data'),
            _ExportTile(
              isLoading: state.exportStatus == ExportStatus.loading,
            ),
            const Divider(height: 1),
            _SectionHeader('Hardware'),
            const _HardwareCapabilityCard(),
            const Divider(height: 1),
            _SectionHeader('Account'),
            const _SignOutTile(),
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
            context.read<SettingsBloc>().add(SettingsLanguageChanged(code));
          }
        },
      ),
    );
  }
}

class _ExportTile extends StatelessWidget {
  final bool isLoading;
  const _ExportTile({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.file_download_outlined),
      title: const Text('Export Timetable'),
      subtitle: const Text('Save schedule as JSON and share'),
      trailing: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right),
      onTap: isLoading
          ? null
          : () => context
              .read<SettingsBloc>()
              .add(const ExportTimetableRequested()),
    );
  }
}

class _HardwareCapabilityCard extends StatefulWidget {
  const _HardwareCapabilityCard();

  @override
  State<_HardwareCapabilityCard> createState() => _HardwareCapabilityCardState();
}

class _HardwareCapabilityCardState extends State<_HardwareCapabilityCard> {
  bool? _bleSupported;
  bool? _nfcAvailable;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      FlutterBluePlus.isSupported,
      NfcManager.instance.isAvailable(),
    ]);
    if (!mounted) return;
    setState(() {
      _bleSupported = results[0];
      _nfcAvailable = results[1];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CapabilityRow(
                icon: Icons.bluetooth,
                label: 'Bluetooth',
                available: _bleSupported,
              ),
              const SizedBox(height: 8),
              _CapabilityRow(
                icon: Icons.nfc,
                label: 'NFC',
                available: _nfcAvailable,
              ),
              const SizedBox(height: 12),
              Text(
                'These capabilities can be used for campus check-in hardware integration.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignOutTile extends StatelessWidget {
  const _SignOutTile();

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthSignOutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    return ListTile(
      leading: Icon(Icons.logout, color: errorColor),
      title: Text('Sign out', style: TextStyle(color: errorColor)),
      onTap: () => _confirmSignOut(context),
    );
  }
}

class _CapabilityRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool? available;

  const _CapabilityRow({
    required this.icon,
    required this.label,
    required this.available,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        if (available == null)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: available! ? cs.primaryContainer : cs.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              available! ? 'Available' : 'Unavailable',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: available! ? cs.onPrimaryContainer : cs.onErrorContainer,
                  ),
            ),
          ),
      ],
    );
  }
}
