import 'package:flutter/material.dart';
import 'package:personal_finance_lite/providers/auth_provider.dart';
import 'package:personal_finance_lite/providers/theme_provider.dart';
import 'package:personal_finance_lite/providers/data_provider.dart';
import 'package:personal_finance_lite/services/export_service.dart';
import 'package:personal_finance_lite/services/shared_prefs_service.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _currency;
  late bool _notifications;
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _currency = await SharedPrefsService.getCurrency();
    _notifications = await SharedPrefsService.getNotificationsEnabled();
    _darkMode = await SharedPrefsService.getTheme() == 'dark';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Currency
          ListTile(
            title: const Text('Currency'),
            trailing: DropdownButton<String>(
              value: _currency,
              items: const [
                DropdownMenuItem(value: '\$', child: Text('USD (\$)')),
                DropdownMenuItem(value: '€', child: Text('EUR (€)')),
                DropdownMenuItem(value: '£', child: Text('GBP (£)')),
                DropdownMenuItem(value: '₹', child: Text('INR (₹)')),
              ],
              onChanged: (val) async {
                _currency = val!;
                await SharedPrefsService.setCurrency(val);
                setState(() {});
              },
            ),
          ),
          // Notifications
          SwitchListTile(
            title: const Text('Enable notifications'),
            value: _notifications,
            onChanged: (val) async {
              _notifications = val;
              await SharedPrefsService.setNotificationsEnabled(val);
              setState(() {});
            },
          ),
          // Dark mode
          SwitchListTile(
            title: const Text('Dark mode'),
            value: _darkMode,
            onChanged: (val) {
              setState(() => _darkMode = val);
              Provider.of<ThemeProvider>(context, listen: false)
                  .toggleTheme(val);
            },
          ),
          const Divider(),
          // Export / Import
          ListTile(
            title: const Text('Export data'),
            subtitle: const Text('Download JSON/CSV backups'),
            trailing: const Icon(Icons.download),
            onTap: () => _showExportDialog(context),
          ),
          ListTile(
            title: const Text('Import data'),
            subtitle: const Text('Restore from JSON file'),
            trailing: const Icon(Icons.upload),
            onTap: () => _importJson(context),
          ),
          const Divider(),
          ListTile(
            title: const Text('Logout'),
            trailing: const Icon(Icons.logout),
            onTap: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    final uid = Provider.of<AuthProvider>(context, listen: false).user!.uid;
    final data = DataProvider(uid);

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('Export JSON'),
              onTap: () async {
                final json = await data.exportAll();
                await ExportService.exportJson(json);
                if (mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export CSV'),
              onTap: () async {
                final json = await data.exportAll();
                await ExportService.exportCsv(json);
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importJson(BuildContext context) async {
    // A full file-picker implementation would require additional packages
    // and permissions.  For brevity we show a placeholder:
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import JSON – implement file picker here')),
    );
  }
}