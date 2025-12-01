import 'package:flutter/material.dart';
import 'package:ledgu/controller/screens_controller/profile_controller.dart';

class UpdateProfilePage extends StatefulWidget {
  final String fullName;
  final String contact;
  final String city;

  const UpdateProfilePage({
    super.key,
    this.fullName = '',
    this.contact = '',
    this.city = '',
  });

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final profileController = ProfileController();

  late TextEditingController _fullNameController;
  late TextEditingController _contactController;
  late TextEditingController _cityController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.fullName);
    _contactController = TextEditingController(text: widget.contact);
    _cityController = TextEditingController(text: widget.city);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _contactController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await profileController.updateUserInfo(
      fullName: _fullNameController.text.trim(),
      contact: _contactController.text.trim(),
      city: _cityController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context, true); // return true to indicate update
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (v) => v!.isEmpty ? "Enter full name" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: "Contact"),
                validator: (v) => v!.isEmpty ? "Enter contact" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: "City"),
                validator: (v) => v!.isEmpty ? "Enter city" : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _updateProfile,
                      child: const Text("Save Changes"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
