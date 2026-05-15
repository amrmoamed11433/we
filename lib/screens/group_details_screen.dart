import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/customer_model.dart';
import '../providers/app_provider.dart';
import '../utils/currency_utils.dart';
import '../utils/date_utils.dart';
import '../widgets/customer_card.dart';
import '../widgets/empty_state.dart';
import 'add_edit_customer_screen.dart';
import 'edit_group_screen.dart';

class GroupDetailsScreen extends StatelessWidget {
  final String groupId;
  const GroupDetailsScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final app = context.watch<AppProvider>();
    final locale = Localizations.localeOf(context).languageCode;

    final group = app.groupById(groupId);
    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.groupDetails)),
        body: Center(child: Text(l.historyEmpty)),
      );
    }

    final customers = app.customersOf(groupId);
    final collected = app.groupCollected(groupId);
    final pending = app.groupPending(groupId);
    final net = app.groupNetProfit(group);

    String money(double v) =>
        CurrencyUtils.format(v, l.currency, locale: locale);

    final cycleEnd =
        CycleDateUtils.getCycleEndDate(group.currentCycleStartDate, group.renewalDay);

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: l.editGroup,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => EditGroupScreen(groupId: groupId)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _kv(context, l.cycleStartDate,
                        CycleDateUtils.formatDate(group.currentCycleStartDate,
                            locale: locale)),
                    _kv(context, l.cycleEndDate,
                        CycleDateUtils.formatDate(cycleEnd, locale: locale)),
                    _kv(
                      context,
                      l.renewalDay,
                      group.renewalDay == 1 ? l.renewalDay1 : l.renewalDay16,
                    ),
                    _kv(context, l.companyCost, money(group.currentCompanyCost)),
                    const Divider(height: 20),
                    _kv(context, l.totalCollected, money(collected),
                        color: Colors.green.shade700),
                    _kv(context, l.totalPending, money(pending),
                        color: Colors.deepOrange.shade700),
                    _kv(context, l.netProfit, money(net),
                        color: net >= 0
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        bold: true),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${l.customerList}  (${customers.length}/6)',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: customers.isEmpty
                  ? EmptyState(
                      icon: Icons.person_add_alt,
                      message: l.noCustomers,
                      actionLabel: l.addFirstCustomer,
                      onAction: () => _addCustomer(context, app, groupId),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                      itemCount: customers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final c = customers[i];
                        return CustomerCard(
                          customer: c,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddEditCustomerScreen(
                                groupId: groupId,
                                customer: c,
                              ),
                            ),
                          ),
                          onTogglePaid: () => _togglePaid(context, app, c),
                          onDelete: () => _confirmDelete(context, app, c),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addCustomer(context, app, groupId),
        icon: const Icon(Icons.add),
        label: Text(l.addCustomer),
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v,
      {Color? color, bool bold = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(k, style: theme.textTheme.bodyMedium)),
          Text(
            v,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addCustomer(
      BuildContext context, AppProvider app, String groupId) async {
    final l = AppLocalizations.of(context);
    if (app.activeCustomerCountOf(groupId) >= AppProvider.maxCustomersPerGroup) {
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
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditCustomerScreen(groupId: groupId),
      ),
    );
  }

  Future<void> _togglePaid(
      BuildContext context, AppProvider app, Customer c) async {
    final l = AppLocalizations.of(context);
    if (c.isPaid) {
      await app.markUnpaid(c.id);
    } else {
      await app.markPaid(c.id);
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.successPaymentUpdated),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, AppProvider app, Customer c) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteCustomerTitle),
        content: Text(l.deleteCustomerMessage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel)),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (ok == true) {
      await app.deleteCustomer(c.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.successDeleted),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}
