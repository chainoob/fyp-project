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
    final uid = context.read<AppAuthProvider>().currentUser?.uid;
    if (uid != null) context.read<ApplianceProvider>().subscribeToUser(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _idx == 3 ? null : AppBar(title: Text(['Dashboard', 'Analytics', 'Appliances'][_idx])),
      body: _pages[_idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Insights'),
          NavigationDestination(icon: Icon(Icons.devices), label: 'Appliances'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  // Helper to show the Edit Goal Dialog
  void _showSetGoalDialog(BuildContext context) {
    final provider = context.read<GoalProvider>();
    final controller = TextEditingController(text: provider.target.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Set Monthly Goal"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Target (kWh)",
            hintText: "e.g. 200",
            border: OutlineInputBorder(),
            suffixText: "kWh",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                provider.setGoal(val);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.ecoTeal),
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. WATCH THE PROVIDER
    final goalProvider = context.watch<GoalProvider>();

    // 2. USE REAL DATA FROM PROVIDER
    final double goalKwh = goalProvider.target;
    final double usedKwh = goalProvider.current;
    final double progress = goalProvider.progress;
    final bool isOver = goalProvider.isOverBudget;

    const String estimatedBill = "RM 0.00";
    const String carbonFootprint = "0 kg";

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.navyBlue, Color(0xFF5C6BC0)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Current Bill Estimate", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              const Text(estimatedBill, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white54, size: 16),
                  SizedBox(width: 4),
                  Text("Analysis pending...", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.navyBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                ),
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

        Row(
          children: [
            Expanded(child: MetricTile(
                label: "Current Load",
                value: "${usedKwh.toStringAsFixed(1)} kWh", // Showing usage here for now
                icon: Icons.electric_bolt,
                color: Colors.amber
            )),
            const SizedBox(width: 16),
            const Expanded(child: MetricTile(label: "Carbon Footprint", value: carbonFootprint, icon: Icons.co2, color: AppTheme.ecoTeal)),
          ],
        ),

        const SizedBox(height: 24),
        const Text("My Goal", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),

        // --- 3. GOAL TRACKING SECTION  ---
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4)
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Monthly Budget", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

                  // EDIT BUTTON
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                    onPressed: () => _showSetGoalDialog(context),
                    tooltip: "Set Goal",
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isOver ? Colors.red : AppTheme.ecoTeal
                      )
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                      isOver ? Colors.redAccent : AppTheme.ecoTeal
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${usedKwh.toStringAsFixed(1)} kWh used",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  Text(
                    goalKwh == 0 ? "Set a goal" : "Goal: ${goalKwh.toStringAsFixed(0)} kWh",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              if (progress > 0.75 || isOver)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: (isOver ? Colors.red : Colors.orange).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Row(
                    children: [
                      Icon(
                          isOver ? Icons.error_outline : Icons.warning_amber_rounded,
                          size: 16,
                          color: isOver ? Colors.red : Colors.orange
                      ),
                      const SizedBox(width: 8),
                      Text(
                          isOver ? "You have exceeded your budget!" : "You are nearing your monthly limit.",
                          style: TextStyle(fontSize: 12, color: isOver ? Colors.red : Colors.orange)
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}