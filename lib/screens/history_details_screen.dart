import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../utils/currency_utils.dart';
import '../utils/date_utils.dart';

class HistoryDetailsScreen extends StatelessWidget {
  final String historyId;
  const HistoryDetailsScreen({super.key, required this.historyId});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final app = context.watch<AppProvider>();
    final locale = Localizations.localeOf(context).languageCode;
    String money(double v) =>
        CurrencyUtils.format(v, l.currency, locale: locale);

    final h = app.db.historyBox.get(historyId);
    if (h == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.historyDetails)),
        body: Center(child: Text(l.historyEmpty)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.historyDetails)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _kv(context, l.groupName, h.groupName),
                    _kv(
                      context,
                      l.cycle,
                      '${CycleDateUtils.formatDate(h.cycleStartDate, locale: locale)} — '
                      '${CycleDateUtils.formatDate(h.cycleEndDate, locale: locale)}',
                    ),
                    const Divider(height: 20),
                    _kv(context, l.totalCollected, money(h.totalCollected),
                        color: Colors.green.shade700),
                    _kv(context, l.totalPending, money(h.totalPending),
                        color: Colors.deepOrange.shade700),
                    _kv(context, l.totalExpectedSales,
                        money(h.totalExpectedSales)),
                    _kv(context, l.companyCost, money(h.companyCost)),
                    _kv(context, l.netProfit, money(h.netProfit),
                        color: h.netProfit >= 0
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                l.snapshot,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            ...h.customersSnapshot.map((c) {
              final color = c.isPaid
                  ? Colors.green.shade600
                  : Colors.deepOrange.shade600;
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(
                      c.isPaid ? Icons.check : Icons.schedule,
                      color: color,
                    ),
                  ),
                  title: Text(c.name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.phone),
                      Text(
                        '${c.gigabytes.toStringAsFixed(0)} GB  •  ${money(c.price)}',
                      ),
                      if (c.isPaid && c.paidDate != null)
                        Text(
                          '${l.lastPaidDate}: ${CycleDateUtils.formatDate(c.paidDate!, locale: locale)}',
                        ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      c.isPaid ? l.paid : l.unpaid,
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v,
      {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(k)),
          Text(
            v,
            style: TextStyle(
              color: color,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
