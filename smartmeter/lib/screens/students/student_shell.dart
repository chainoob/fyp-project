import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeter/controllers/provider.dart';
import '../../config/theme.dart';
import 'package:smartmeter/widgets/reusable_widget.dart';
import '../shared/profile_screen.dart';
import '../shared/appliances_screen.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});
  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _idx = 0;
  final _pages = const [StudentDashboard(), Placeholder(), AppliancesScreen(), ProfileScreen()];

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null) context.read<ApplianceProvider>().subscribeToUser(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _idx == 3 ? null : AppBar(title: Text(['Dashboard', 'Analytics', 'My Devices'][_idx])),
      body: _pages[_idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Insights'),
          NavigationDestination(icon: Icon(Icons.devices), label: 'Devices'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.navyBlue, Color(0xFF5C6BC0)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Current Bill Estimate", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              const Text("\$45.20", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.navyBlue),
                onPressed: () {}, 
                icon: const Icon(Icons.analytics_outlined, size: 18),
                label: const Text("ANALYZE USAGE"),
              )
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text("Real-Time Metrics", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(child: MetricTile(label: "Current Load", value: "1.2 kW", icon: Icons.electric_bolt, color: Colors.amber)),
            SizedBox(width: 16),
            Expanded(child: MetricTile(label: "Carbon Footprint", value: "4.5 kg", icon: Icons.co2, color: AppTheme.ecoTeal)),
          ],
        ),
      ],
    );
  }
}