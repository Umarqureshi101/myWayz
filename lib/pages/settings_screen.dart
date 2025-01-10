import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // For language selection
  String _selectedLanguage = "English";

  // For notification settings
  bool _allowNotifications = true;
  bool _showPreviews = true;
  bool _sound = false;

  void _showHelpSupportModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            "Help & Support",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: Text("For assistance, email us at umarqureshi101@gmail.com."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            "Select Language",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: Text("English"),
                value: "English",
                groupValue: _selectedLanguage,
                onChanged: (String? value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile(
                title: Text("UK English"),
                value: "UK English",
                groupValue: _selectedLanguage,
                onChanged: (String? value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile(
                title: Text("US English"),
                value: "US English",
                groupValue: _selectedLanguage,
                onChanged: (String? value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            "Notification Settings",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text("Allow Notifications"),
                value: _allowNotifications,
                onChanged: (bool value) {
                  setState(() {
                    _allowNotifications = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text("Show Previews"),
                value: _showPreviews,
                onChanged: (bool value) {
                  setState(() {
                    _showPreviews = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text("Sound"),
                value: _sound,
                onChanged: (bool value) {
                  setState(() {
                    _sound = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.blueAccent, // Dark Blue Background
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[700]!, Colors.blue[50]!], // Light to Dark Blue Gradient
          ),
        ),
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.notifications, color: Colors.white),
              title: Text(
                "Notifications",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onTap: () => _showNotificationsModal(context),
            ),
            Divider(color: Colors.white),
            ListTile(
              leading: Icon(Icons.privacy_tip, color: Colors.white),
              title: Text(
                "Privacy",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // Do nothing for now
              },
            ),
            Divider(color: Colors.white),
            ListTile(
              leading: Icon(Icons.language, color: Colors.white),
              title: Text(
                "Language",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onTap: () => _showLanguageModal(context),
            ),
            Divider(color: Colors.white),
            ListTile(
              leading: Icon(Icons.help, color: Colors.white),
              title: Text(
                "Help & Support",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onTap: () => _showHelpSupportModal(context),
            ),
            Divider(color: Colors.white),
            ListTile(
              leading: Icon(Icons.help, color: Colors.white),
              title: Text(
                "About",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
