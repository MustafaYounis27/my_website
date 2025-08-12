import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../state/cv_provider.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _authorized = false;
  final _passwordCtrl = TextEditingController();
  final _jsonCtrl = TextEditingController();
  static const _passwordKey = 'admin_password_ok';
  static const _defaultPass = 'admin123';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _authorized = prefs.getBool(_passwordKey) ?? false);
    final cv = context.read<CVProvider>().cv;
    if (cv != null) {
      // Not the original JSON, but allow editing using current provider JSON snapshot
      // In a full app, we'd fetch the original text. Here, we keep it simple.
    }
    final override = prefs.getString('cv_override_json');
    if (override != null) _jsonCtrl.text = override;
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _jsonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin (local)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _authorized ? _buildEditor(context) : _buildLogin(context),
      ),
    );
  }

  Widget _buildLogin(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Enter password to edit (stored in browser only):'),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    if (_passwordCtrl.text == _defaultPass) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool(_passwordKey, true);
                      setState(() => _authorized = true);
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong password')));
                      }
                    }
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    final cvProvider = context.watch<CVProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Local JSON editor (persists to browser storage only).'),
        const SizedBox(height: 12),
        Expanded(
          child: TextField(
            controller: _jsonCtrl,
            maxLines: null,
            expands: true,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.preview),
              label: const Text('Preview'),
              onPressed: () async {
                await cvProvider.loadFromString(_jsonCtrl.text);
              },
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save override'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('cv_override_json', _jsonCtrl.text);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
                }
              },
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              icon: const Icon(Icons.restore),
              label: const Text('Reset to asset'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('cv_override_json');
                await cvProvider.load();
              },
            ),
          ],
        ),
      ],
    );
  }
}
