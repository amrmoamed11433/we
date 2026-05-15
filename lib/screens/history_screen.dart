import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../utils/currency_utils.dart';
import '../utils/date_utils.dart';
import '../widgets/empty_state.dart';
import 'history_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? _filterGroupId; // null = all

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final app = context.watch<AppProvider>();
    final locale = Localizations.localeOf(context).languageCode;
    String money(double v) =>
        CurrencyUtils.format(v, l.currency, locale: locale);

    final items = app.history(groupId: _filterGroupId);

    return Scaffold(
      appBar: AppBar(title: Text(l.historyTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: DropdownButtonFormField<String?>(
                value: _filterGroupId,
                decoration: InputDecoration(
                  labelText: l.filterByGroup,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                ),
                items: [
                  DropdownMenuItem<String?>(
                      value: null, child: Text(l.filterAll)),
                  ...app.groups.map(
                    (g) => DropdownMenuItem<String?>(
                      value: g.id,
                      child: Text(g.name),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _filterGroupId = v),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? EmptyState(
                      icon: Icons.history,
                      message: l.historyEmpty,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final h = items[i];
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                                color: Theme.of(context).dividerColor),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            title: Text(
                              h.groupName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  '${CycleDateUtils.formatDate(h.cycleStartDate, locale: locale)}'
                                  '  —  '
                                  '${CycleDateUtils.formatDate(h.cycleEndDate, locale: locale)}',
                                ),
                                const SizedBox(height: 4),
                                Text(
                                    '${l.totalCollected}: ${money(h.totalCollected)}'),
                                Text(
                                    '${l.totalPending}: ${money(h.totalPending)}'),
                                Text(
                                    '${l.companyCost}: ${money(h.companyCost)}'),
                                Text(
                                  '${l.netProfit}: ${money(h.netProfit)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: h.netProfit >= 0
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    HistoryDetailsScreen(historyId: h.id),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
