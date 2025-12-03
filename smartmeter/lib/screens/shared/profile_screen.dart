import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeter/controllers/provider.dart';
import '../../config/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.navyBlue, Color(0xFF1A237E)]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              CircleAvatar(radius: 32, backgroundColor: Colors.white12, child: Text(user.name[0], style: const TextStyle(fontSize: 24, color: Colors.white))),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(user.role.toUpperCase(), style: const TextStyle(color: AppTheme.ecoTeal, letterSpacing: 1.2, fontSize: 12)),
                  if (user.studentId != null) Text("ID: ${user.studentId}", style: const TextStyle(color: Colors.white70)),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text("Log Out"),
          onTap: () => context.read<AuthProvider>().logout(),
        )
      ],
    );
  }
}