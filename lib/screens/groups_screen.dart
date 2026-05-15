import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../widgets/group_card.dart';
import 'group_details_screen.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final app = context.watch<AppProvider>();
    final groups = app.groups;

    return Scaffold(
      appBar: AppBar(title: Text(l.groupsTitle)),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: groups.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final g = groups[i];
            return GroupCard(
              group: g,
              provider: app,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GroupDetailsScreen(groupId: g.id),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
