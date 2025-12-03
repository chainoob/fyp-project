import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smartmeter/controllers/provider.dart';
import 'package:smartmeter/widgets/reusable_widget.dart';
import 'package:smartmeter/config/theme.dart';

class AppliancesScreen extends StatelessWidget {
  const AppliancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final list = context.watch<ApplianceProvider>().appliances;
    final isStaff = context.read<AuthProvider>().isStaff;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: isStaff 
          ? null 
          : FloatingActionButton.extended(
              onPressed: () => _showRegistrationModal(context),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Register Device"),
              backgroundColor: AppTheme.ecoTeal,
              foregroundColor: Colors.white,
              elevation: 4,
            ),
      body: list.isEmpty 
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80),
              itemCount: list.length,
              itemBuilder: (ctx, i) => ApplianceCard(app: list[i]),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices_other, size: 64, color: Colors.grey[800]),
          const SizedBox(height: 16),
          Text(
            "No Devices Registered",
            style: TextStyle(color: Colors.grey[500], fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            "Please register your device",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showRegistrationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _RegistrationForm(),
    );
  }
}

class _RegistrationForm extends StatefulWidget {
  const _RegistrationForm();

  @override
  State<_RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<_RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameCtrl = TextEditingController();
  final _wattCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();

  final _wattFocus = FocusNode();
  final _roomFocus = FocusNode();

  String _selectedType = 'Laptop';
  bool _isSubmitting = false;

  final List<String> _deviceTypes = [
    'Laptop', 'Iron', 'Kettle', 'Fan', 'Phone Charger', 'Lamp', 'Other'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _wattCtrl.dispose();
    _roomCtrl.dispose();
    _wattFocus.dispose();
    _roomFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);

    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) throw "Authentication session expired. Please login again.";

      await context.read<ApplianceProvider>().add(
        user.uid,
        _nameCtrl.text.trim(),
        _selectedType.toLowerCase(),
        int.parse(_wattCtrl.text.trim()),
        _roomCtrl.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Request Submitted. Device is pending approval."),
            backgroundColor: AppTheme.ecoTeal,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Submission Failed: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handling keyboard overlay
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset,
        left: 24, 
        right: 24, 
        top: 24
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Register New Device", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () => Navigator.pop(context), 
                    icon: const Icon(Icons.close),
                    tooltip: "Cancel",
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Placeholder for TensorFlow Lite integration (Phase 2)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white12, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF1A1B1E),
                ),
                child: Column(
                  children: [
                    Icon(Icons.qr_code_scanner, color: AppTheme.ecoTeal.withValues(alpha: 0.7), size: 32),
                    const SizedBox(height: 12),
                    const Text("Quick Scan (Coming Soon)", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text(
                      "Automatically detect wattage from appliance labels.",
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _nameCtrl,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_wattFocus),
                      decoration: const InputDecoration(
                        labelText: "Device Name", 
                      ),
                      validator: (v) => v == null || v.length < 3 ? "Enter a valid name" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _selectedType,
                      dropdownColor: AppTheme.surface,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: "Type"),
                      items: _deviceTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setState(() => _selectedType = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _wattCtrl,
                      focusNode: _wattFocus,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_roomFocus),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(labelText: "Wattage", suffixText: "W"),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Required";
                        final w = int.tryParse(v);
                        if (w == null || w <= 0) return "Invalid";
                        if (w > 5000) return "Max 5000W";
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _roomCtrl,
                      focusNode: _roomFocus,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(labelText: "Location", hintText: "e.g. Bed A"),
                      validator: (v) => v == null || v.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.navyBlue,
                    disabledBackgroundColor: AppTheme.navyBlue.withValues(alpha: 0.5),
                  ),
                  child: _isSubmitting 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Text("SUBMIT FOR VERIFICATION", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 32), 
            ],
          ),
        ),
      ),
    );
  }
}