import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../utils/validators.dart';

class EditGroupScreen extends StatefulWidget {
  final String groupId;
  const EditGroupScreen({super.key, required this.groupId});

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _cost;
  int _renewalDay = 1;

  @override
  void initState() {
    super.initState();
    final g = context.read<AppProvider>().groupById(widget.groupId);
    _name = TextEditingController(text: g?.name ?? '');
    _cost = TextEditingController(text: g?.currentCompanyCost.toString() ?? '0');
    _renewalDay = g?.renewalDay ?? 1;
  }

  @override
  void dispose() {
    _name.dispose();
    _cost.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l = AppLocalizations.of(context);
    final app = context.read<AppProvider>();
    await app.updateGroup(
      id: widget.groupId,
      name: _name.text.trim(),
      renewalDay: _renewalDay,
      companyCost: double.parse(_cost.text.trim()),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.successSaved),
        duration: const Duration(seconds: 1),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.editGroup)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: l.groupName,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => Validators.required(context, v),
              ),
              const SizedBox(height: 16),
              Text(l.renewalDay,
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: [
                  ButtonSegment(value: 1, label: Text(l.renewalDay1)),
                  ButtonSegment(value: 16, label: Text(l.renewalDay16)),
                ],
                selected: {_renewalDay},
                onSelectionChanged: (s) =>
                    setState(() => _renewalDay = s.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cost,
                decoration: InputDecoration(
                  labelText: l.currentCompanyCost,
                  border: const OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) =>
                    Validators.requiredNumberGreaterOrEqualZero(context, v),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: Text(l.saveGroup),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
