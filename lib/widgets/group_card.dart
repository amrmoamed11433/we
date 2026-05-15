import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/group_model.dart';
import '../providers/app_provider.dart';
import '../utils/currency_utils.dart';

class GroupCard extends StatelessWidget {
  final Group group;
  final AppProvider provider;
  final VoidCallback onTap;

  const GroupCard({
    super.key,
    required this.group,
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final collected = provider.groupCollected(group.id);
    final pending = provider.groupPending(group.id);
    final cost = group.currentCompanyCost;
    final net = provider.groupNetProfit(group);
    final count = provider.activeCustomerCountOf(group.id);

    final locale = Localizations.localeOf(context).languageCode;
    String money(double v) => CurrencyUtils.format(v, l.currency, locale: locale);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.group, color: theme.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${l.renewalDay}: '
                          '${group.renewalDay == 1 ? l.renewalDay1 : l.renewalDay16}'
                          '  •  $count/6',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 12),
              _MiniStat(
                label: l.totalCollected,
                value: money(collected),
                color: Colors.green,
              ),
              _MiniStat(
                label: l.totalPending,
                value: money(pending),
                color: Colors.orange,
              ),
              _MiniStat(
                label: l.totalCompanyCosts,
                value: money(cost),
                color: Colors.blueGrey,
              ),
              _MiniStat(
                label: l.netProfit,
                value: money(net),
                color: net >= 0 ? Colors.green : Colors.red,
                emphasize: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool emphasize;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
