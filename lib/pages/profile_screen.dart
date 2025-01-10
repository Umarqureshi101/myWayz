import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialDob;
  final String initialGender;
  final Function(String, String, String, String) onSave; // Callback to save user profile

  ProfileScreen({
    required this.initialName,
    required this.initialEmail,
    required this.initialDob,
    required this.initialGender,
    required this.onSave,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.initialName;
    emailController.text = widget.initialEmail;
    dobController.text = widget.initialDob;
    selectedGender = widget.initialGender;
  }

  void saveProfile() {
    // Call the passed function to update the profile with additional details
    widget.onSave(
      nameController.text,
      emailController.text,
      dobController.text,
      selectedGender!,
    );
    Navigator.pop(context); // Close the profile screen after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Light blue background
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1E88E5), // Blue color for the AppBar
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFF1E88E5), // Blue back icon
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 32),
              const Text(
                "Let's Make Your Profile!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E88E5), // Blue text color
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Fill these information so that people can know you better.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              // Name Field
              _buildLabel("Name"),
              const SizedBox(height: 8),
              _buildTextField(nameController, 'Enter your name'),
              const SizedBox(height: 24),
              // Email Field
              _buildLabel("E-mail"),
              const SizedBox(height: 8),
              _buildTextField(emailController, 'Enter your email'),
              const SizedBox(height: 24),
              // Date of Birth Field
              _buildLabel("Date of Birth"),
              const SizedBox(height: 8),
              _buildTextField(dobController, 'Enter your date of birth', keyboardType: TextInputType.datetime),
              const SizedBox(height: 24),
              // Gender Selection
              _buildLabel("Gender"),
              const SizedBox(height: 8),
              _buildGenderDropdown(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1E88E5), // Blue button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const SizedBox(
                  height: 60.0,
                  child: Center(
                    child: Text(
                      'Save Profile',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create label and required asterisk
  Widget _buildLabel(String label) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          " *",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.pinkAccent,
          ),
        ),
      ],
    );
  }

  // Helper method to create a TextFormField widget
  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0),
        ),
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF1E88E5)), // Blue label text
      ),
      keyboardType: keyboardType,
    );
  }

  // Helper method to create a DropdownButtonFormField for Gender selection
  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      onChanged: (String? newValue) {
        setState(() {
          selectedGender = newValue;
        });
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      items: <String>['Male', 'Female', 'Other']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(color: Color(0xFF1E88E5))), // Blue text for options
        );
      }).toList(),
    );
  }
}
