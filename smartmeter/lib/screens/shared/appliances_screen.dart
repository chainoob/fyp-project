import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeter/controllers/provider.dart';
import 'package:smartmeter/widgets/reusable_widget.dart';

class AppliancesScreen extends StatelessWidget {
  const AppliancesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final list = context.watch<ApplianceProvider>().appliances;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (ctx, i) => ApplianceCard(app: list[i]),
    );
  }
}