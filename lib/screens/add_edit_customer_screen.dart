import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/customer_model.dart';
import '../providers/app_provider.dart';
import '../utils/validators.dart';

class AddEditCustomerScreen extends StatefulWidget {
  final String groupId;
  final Customer? customer;

  const AddEditCustomerScreen({
    super.key,
    required this.groupId,
    this.customer,
  });

  @override
  State<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends State<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _phone;
  late TextEditingController _gb;
  late TextEditingController _price;
  late TextEditingController _notes;

  bool get _isEdit => widget.customer != null;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _name = TextEditingController(text: c?.name ?? '');
    _phone = TextEditingController(text: c?.phone ?? '');
    _gb = TextEditingController(text: c == null ? '' : c.gigabytes.toString());
    _price = TextEditingController(text: c == null ? '' : c.price.toString());
    _notes = TextEditingController(text: c?.notes ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _gb.dispose();
    _price.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    final app = context.read<AppProvider>();
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    final gb = double.parse(_gb.text.trim());
    final price = double.parse(_price.text.trim());
    final notes = _notes.text.trim();

    if (_isEdit) {
      await app.updateCustomer(
        id: widget.customer!.id,
        name: name,
        phone: phone,
        gigabytes: gb,
        price: price,
        notes: notes,
      );
    } else {
      final added = await app.addCustomer(
        groupId: widget.groupId,
        name: name,
        phone: phone,
        gigabytes: gb,
        price: price,
        notes: notes,
      );
      if (!added) {
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l.groupFullTitle),
            content: Text(l.groupFullMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l.ok),
              ),
            ],
          ),
        );
        return;
      }
    }
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
      appBar: AppBar(
        title: Text(_isEdit ? l.editCustomer : l.addNewCustomer),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: l.customerName,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => Validators.required(context, v),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                decoration: InputDecoration(
                  labelText: l.phoneNumber,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => Validators.required(context, v),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _gb,
                decoration: InputDecoration(
                  labelText: l.gigabytes,
                  border: const OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) =>
                    Validators.requiredNumberGreaterThanZero(context, v),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _price,
                decoration: InputDecoration(
                  labelText: l.price,
                  border: const OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) =>
                    Validators.requiredNumberGreaterOrEqualZero(context, v),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                decoration: InputDecoration(
                  labelText: l.notes,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: Text(l.saveCustomer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
