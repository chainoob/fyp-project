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
    Placeholder(),
    ProfileScreen()
  ];

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

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Campus Overview"));
}

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
      itemBuilder: (ctx, i) {
        return _VerificationCard(app: pending[i]);
      },
    );
  }
}

// Extracted to manage "Processing" state per card
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
      if (isApprove) {
        await provider.approve(widget.app.ownerId, widget.app.id);
      } else {
        await provider.reject(widget.app.ownerId, widget.app.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isApprove ? "Device Approved" : "Application Rejected"),
          backgroundColor: isApprove ? AppTheme.ecoTeal : Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
      // Note: The card will automatically be removed from the parent list
      // because the stream will update, so we don't need to manually remove it.
    } catch (e) {
      if (mounted) {
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
            // Status Badge & Type
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

                // Approve Button
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