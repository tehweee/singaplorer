import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Header with profile info and back button
          Container(
            color: Color(0xFFB00020),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Back button
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 10),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(Icons.person, color: Colors.black),
                    ),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'JaneDoe',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Token Available: 5',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Account and Information sections
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Section
                    Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    AccountOption(title: 'Change Email', icon: Icons.email),
                    AccountOption(
                      title: 'Language Preference',
                      icon: Icons.language,
                    ),
                    AccountOption(
                      title: 'Notification Preference',
                      icon: Icons.notifications,
                    ),
                    AccountOption(title: 'Time Zone', icon: Icons.access_time),

                    SizedBox(height: 24),

                    // Information Section
                    Text(
                      'Information',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    AccountOption(title: 'App Theme', icon: Icons.palette),
                    AccountOption(
                      title: 'Terms and Conditions',
                      icon: Icons.article,
                    ),
                    AccountOption(
                      title: 'Privacy Policy',
                      icon: Icons.privacy_tip,
                    ),
                    AccountOption(title: 'App Version', icon: Icons.info),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFB00020),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favourites'),
          BottomNavigationBarItem(icon: Icon(Icons.support), label: 'Support'),
        ],
      ),
    );
  }
}

class AccountOption extends StatelessWidget {
  final String title;
  final IconData icon;

  const AccountOption({Key? key, required this.title, required this.icon})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFFB00020), size: 28),
          SizedBox(width: 16),
          Text(title, style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
