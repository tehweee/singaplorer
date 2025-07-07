import 'package:flutter/material.dart';
import 'package:profile_test_isp/pages/SettingPage.dart';

class EditProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EditProfileScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Stack(
        children: [
          // White profile container
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
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
                  const ProfileField(label: 'Name:', value: 'JaneDoe'),
                  const ProfileField(label: 'Username:', value: 'JaneD03'),
                  const ProfileField(label: 'Email:', value: 'jane69@mail.lol'),
                  const ProfileField(
                    label: 'Nationality:',
                    value: 'Singaporean',
                  ),
                  const ProfileField(label: 'Language:', value: 'English'),
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
                  const ProfileField(
                    label: 'Travel Preference:',
                    value: 'Relax, Food, Nature, Adventure',
                  ),
                ],
              ),
            ),
          ),

          // Profile avatar
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

          // Settings icon with navigation
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
      ),

      // Bottom Navigation Bar
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
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
