import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../utils/currency_utils.dart';
import '../widgets/group_card.dart';
import '../widgets/summary_card.dart';
import 'group_details_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final app = context.watch<AppProvider>();
    final locale = Localizations.localeOf(context).languageCode;
    String money(double v) =>
        CurrencyUtils.format(v, l.currency, locale: locale);

    final groups = app.groups;

    return Scaffold(
      appBar: AppBar(title: Text(l.dashboardTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Top row of summary cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: [
                SummaryCard(
                  title: l.totalCollected,
                  value: money(app.dashboardTotalCollected),
                  icon: Icons.savings,
                  color: Colors.green.shade600,
                ),
                SummaryCard(
                  title: l.totalPending,
                  value: money(app.dashboardTotalPending),
                  icon: Icons.hourglass_top,
                  color: Colors.orange.shade700,
                ),
                SummaryCard(
                  title: l.totalExpectedSales,
                  value: money(app.dashboardExpectedSales),
                  icon: Icons.trending_up,
                  color: Colors.indigo.shade600,
                ),
                SummaryCard(
                  title: l.totalCompanyCosts,
                  value: money(app.dashboardCompanyCosts),
                  icon: Icons.account_balance,
                  color: Colors.blueGrey.shade700,
                ),
                SummaryCard(
                  title: l.netProfit,
                  value: money(app.dashboardNetProfit),
                  icon: Icons.payments,
                  color: app.dashboardNetProfit >= 0
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
                SummaryCard(
                  title: '${l.paidCustomers} / ${l.unpaidCustomers}',
                  value:
                      '${app.paidCustomersCount} / ${app.unpaidCustomersCount}',
                  icon: Icons.people,
                  color: Colors.deepPurple.shade600,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                l.currentCycles,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            ...groups.map(
              (g) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GroupCard(
                  group: g,
                  provider: app,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GroupDetailsScreen(groupId: g.id),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
