import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:profile_test_isp/pages/SettingPage.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late Future<Map<String, dynamic>> userData;

  Future<Map<String, dynamic>> fetchUserData() async {
    final uri = Uri.parse(
      "http://10.0.2.2:3000/api/user",
    ); // Replace with real IP in production
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return (jsonBody is Map<String, dynamic>) ? jsonBody : {};
    } else {
      throw Exception("Failed to load user data");
    }
  }

  @override
  void initState() {
    super.initState();
    userData = fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: FutureBuilder<Map<String, dynamic>>(
        future: userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Error loading profile",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final user = snapshot.data ?? {};
          final name = user['name'] ?? '???';
          final username = user['username'] ?? '???';
          final email = user['email'] ?? '???';
          final nationality = user['nationality'] ?? 'No Data';
          final language = user['language'] ?? 'No Data';
          final preferences =
              (user['preferences'] is List && user['preferences'].isNotEmpty)
              ? (user['preferences'] as List).join(', ')
              : 'No Data';

          return Stack(
            children: [
              Positioned(
                top: 120,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 60,
                  ),
                  child: ListView(
                    children: [
                      const Center(
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ProfileField(label: 'Username', value: username),
                      ProfileField(label: 'Email', value: email),
                      ProfileField(label: 'Nationality', value: nationality),
                      ProfileField(label: 'Language', value: language),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Text(
                            'Change Language',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),
                      ProfileField(
                        label: 'Travel Preference',
                        value: preferences,
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Colors.black),
                  ),
                ),
              ),

              Positioned(
                top: 30,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                  },
                  child: Icon(Icons.settings, color: Colors.white, size: 30),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'About',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favourites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent),
            label: 'Support',
          ),
        ],
      ),
    );
  }
}

class ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 24, color: Colors.black),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
