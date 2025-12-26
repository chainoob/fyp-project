import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeter/controllers/provider.dart';
import '../../config/theme.dart';
import '../shared/profile_screen.dart';
import 'package:smartmeter/models/app_model.dart';

class StaffShell extends StatefulWidget {
  const StaffShell({super.key});
  @override
  State<StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends State<StaffShell> {
  int _idx = 0;

  final _pages = const [
    StaffDashboard(),
    VerificationQueue(),
    StaffReportsPage(),
    ProfileScreen()
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplianceProvider>().subscribeToQueue();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _idx == 3
          ? null
          : AppBar(
        title: Text(
          ['Campus Overview', 'Verification Queue', 'Reports'][_idx],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: IndexedStack(
        index: _idx,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        backgroundColor: Colors.white,
        elevation: 3,
        indicatorColor: AppTheme.ecoTeal.withValues(alpha: 0.2),
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

// --- 1. STAFF DASHBOARD ---
class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // --- TODO: INTEGRATION POINTS ---
    // 1. Fetch real-time power usage from 'campus_energy' collection or MQTT stream
    final double campusLoadKw = 0.0;

    // 2. Fetch daily total from aggregation functions or history collection
    final double dailyTotalKwh = 0.0;

    // 3. Query 'alerts' collection where status == 'active'
    final int alertCount = 0;
    // --------------------------------

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // A. Real-Time Monitor
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF263238), Color(0xFF37474F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
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
                  const Text("Real-Time Campus Load", style: TextStyle(color: Colors.white70)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: campusLoadKw > 0 ? Colors.redAccent.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: campusLoadKw > 0 ? Colors.redAccent.withValues(alpha: 0.5) : Colors.grey)
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: campusLoadKw > 0 ? Colors.redAccent : Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                            campusLoadKw > 0 ? "LIVE" : "OFFLINE",
                            style: TextStyle(color: campusLoadKw > 0 ? Colors.redAccent : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Text(
                  "${campusLoadKw.toStringAsFixed(1)} kW",
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.history, color: Colors.white54, size: 16),
                  const SizedBox(width: 4),
                  Text("Total Today: ${dailyTotalKwh.toStringAsFixed(0)} kWh", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        const Text("Management Console", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 16),

        // B. Management Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _AdminCard(
              title: "Manage\nBlocks",
              icon: Icons.apartment,
              color: AppTheme.navyBlue,
              onTap: () {
                // TODO: Navigate to Block List Screen
              },
            ),
            _AdminCard(
              title: "Set Energy\nPlan",
              icon: Icons.tune,
              color: AppTheme.ecoTeal,
              onTap: () {
                // TODO: Open Energy Plan Dialog
              },
            ),
            _AdminCard(
              title: "Overload\nAlerts",
              icon: Icons.notifications_active_outlined,
              color: Colors.orange[800]!,
              badge: alertCount,
              onTap: () {
                // TODO: Navigate to Alerts Screen
              },
            ),
            _AdminCard(
              title: "System\nHealth",
              icon: Icons.monitor_heart_outlined,
              color: Colors.grey[700]!,
              onTap: () {
                // TODO: Run System Diagnostics
              },
            ),
          ],
        ),
      ],
    );
  }
}

// --- 2. REPORTS PAGE ---
class StaffReportsPage extends StatelessWidget {
  const StaffReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- TODO: INTEGRATION POINTS ---
    // 1. Fetch report metadata from Firestore (Collection: 'reports')
    // 2. Map data to this list structure
    final List<Map<String, String>> reports = [];

    // 3. Fetch latest generated report status
    final String latestReportTitle = "No Reports Generated";
    final String latestReportStatus = "System will generate monthly summaries automatically.";

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.navyBlue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.cloud_download, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(latestReportTitle, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(latestReportStatus, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              if (reports.isNotEmpty)
                const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16)
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text("History", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),

        if (reports.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 32),
            child: Center(child: Text("No report history found", style: TextStyle(color: Colors.grey))),
          )
        else
          ...reports.map((r) => _buildReportItem(context, r['title']!, r['size']!)),
      ],
    );
  }

  Widget _buildReportItem(BuildContext context, String title, String size) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(size),
        trailing: IconButton(
          icon: const Icon(Icons.download_rounded, color: AppTheme.ecoTeal),
          onPressed: () {
            // TODO: Implement PDF Download using url_launcher or dio
          },
        ),
      ),
    );
  }
}

// --- 3. VERIFICATION QUEUE (Unchanged Logic) ---
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
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: AppTheme.ecoTeal.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text("All Caught Up!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("No appliances waiting for verification.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length,
      itemBuilder: (ctx, i) => _VerificationCard(app: pending[i]),
    );
  }
}

class _VerificationCard extends StatefulWidget {
  final Appliance app;
  const _VerificationCard({required this.app});

  @override
  State<_VerificationCard> createState() => _VerificationCardState();
}

class _VerificationCardState extends State<_VerificationCard> {
  bool _isProcessing = false;

  Future<void> _handleAction(BuildContext context, bool isApprove) async {
    setState(() => _isProcessing = true);
    final provider = context.read<ApplianceProvider>();

    try {
      // TODO: Ensure backend updates 'appliances' collection: set isApproved = true/false
      if (isApprove) {
        await provider.approve(widget.app.ownerId, widget.app.id);
      } else {
        await provider.reject(widget.app.ownerId, widget.app.id);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isApprove ? "Device Approved" : "Application Rejected"),
          backgroundColor: isApprove ? AppTheme.ecoTeal : Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Action Failed: $e"),
          backgroundColor: Colors.red,
        ));
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                  child: const Text("PENDING REVIEW", style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                Text(widget.app.type.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.app.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("${widget.app.wattage} Watts • ${widget.app.room ?? 'Unknown Room'}", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isProcessing ? null : () => _handleAction(context, false),
                  child: const Text("REJECT", style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isProcessing ? null : () => _handleAction(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.ecoTeal,
                    disabledBackgroundColor: AppTheme.ecoTeal.withValues(alpha: 0.5),
                  ),
                  child: _isProcessing
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("APPROVE"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// --- HELPER: Admin Card ---
class _AdminCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int? badge;
  final VoidCallback onTap;

  const _AdminCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey[800], height: 1.2)),
                ],
              ),
              if (badge != null && badge! > 0)
                Positioned(
                  right: 0, top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    child: Text("$badge", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}