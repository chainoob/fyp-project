import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeter/controllers/provider.dart';
import '../../config/theme.dart';
import '../shared/profile_screen.dart';

class StaffShell extends StatefulWidget {
  const StaffShell({super.key});
  @override
  State<StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends State<StaffShell> {
  int _idx = 0;
  final _pages = const [StaffDashboard(), VerificationQueue(), Placeholder(), ProfileScreen()];

  @override
  void initState() {
    super.initState();
    context.read<ApplianceProvider>().subscribeToQueue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _idx == 3 ? null : AppBar(title: Text(['Campus Overview', 'Verification Queue', 'Reports'][_idx])),
      body: _pages[_idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.admin_panel_settings_outlined), label: 'Campus'),
          NavigationDestination(icon: Icon(Icons.playlist_add_check), label: 'Verify'),
          NavigationDestination(icon: Icon(Icons.assessment_outlined), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class StaffDashboard extends StatelessWidget { const StaffDashboard({super.key}); @override Widget build(BuildContext context) => const Center(child: Text("Campus Overview")); }

class VerificationQueue extends StatelessWidget {
  const VerificationQueue({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplianceProvider>();
    final pending = provider.appliances; 

    if (pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_outline, size: 64, color: AppTheme.ecoTeal),
            SizedBox(height: 16),
            Text("No appliances waiting for verification.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length,
      itemBuilder: (ctx, i) {
        final app = pending[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                    child: const Text("PENDING REVIEW", style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  Text(app.type.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ]),
                const SizedBox(height: 12),
                Text(app.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("${app.wattage} Watts • ${app.room ?? 'Unknown Room'}", style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () {}, child: const Text("REJECT", style: TextStyle(color: Colors.red))),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.ecoTeal), child: const Text("APPROVE")),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}