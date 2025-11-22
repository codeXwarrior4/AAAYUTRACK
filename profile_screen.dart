// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final box = Hive.box('aayutrack_box');

  final TextEditingController _name = TextEditingController();
  final TextEditingController _age = TextEditingController();
  final TextEditingController _gender = TextEditingController();
  final TextEditingController _blood = TextEditingController();
  final TextEditingController _abha = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _contact = TextEditingController();
  final TextEditingController _allergies = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final data = box.get('profile', defaultValue: {});
    _name.text = data['name'] ?? "";
    _age.text = data['age'] ?? "";
    _gender.text = data['gender'] ?? "";
    _blood.text = data['blood'] ?? "";
    _abha.text = data['abha'] ?? "";
    _address.text = data['address'] ?? "";
    _contact.text = data['contact'] ?? "";
    _allergies.text = data['allergies'] ?? "";
  }

  Widget field(TextEditingController c, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    await box.put("profile", {
      "name": _name.text,
      "age": _age.text,
      "gender": _gender.text,
      "blood": _blood.text,
      "abha": _abha.text,
      "address": _address.text,
      "contact": _contact.text,
      "allergies": _allergies.text,
    });

    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _saving = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile saved")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.person_pin_circle, size: 120, color: kTeal),
            const SizedBox(height: 16),
            Text(
              "Personal Profile",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: kTeal,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            field(_name, "Full name", Icons.person),
            field(_age, "Age", Icons.cake),
            field(_gender, "Gender", Icons.wc),
            field(_blood, "Blood group", Icons.bloodtype),
            field(_abha, "ABHA / Govt ID", Icons.badge),
            field(_address, "Address", Icons.home),
            field(_contact, "Emergency Contact", Icons.phone),
            field(_allergies, "Allergies", Icons.warning),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_saving ? "Saving..." : "Save Profile"),
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: kTeal,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
