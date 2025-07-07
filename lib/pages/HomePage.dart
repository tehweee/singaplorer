import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _username = 'Explorer';
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Simulate loading delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFAA0000)),
            )
          : SafeArea(
              child: Column(
                children: [
                  // Top section with profile and search
                  Container(
                    color: const Color(0xFFAA0000),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Profile circle
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Color(0xFFAA0000),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Search bar
                            Expanded(
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Search',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.search,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Title text
                        const Text(
                          'Time to explore Singapore',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Navigate the home menu to select your itinerary',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // White curved section
                  Container(
                    decoration: const BoxDecoration(color: Color(0xFFAA0000)),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),

                            // Menu options
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildMenuOption(
                                  icon: Icons.flight_takeoff,
                                  label: 'Plan Now',
                                ),
                                _buildMenuOption(
                                  icon: Icons.auto_awesome,
                                  label: 'AI Plan',
                                ),
                                _buildMenuOption(
                                  icon: Icons.map,
                                  label: 'Maps',
                                ),
                                _buildMenuOption(
                                  icon: Icons.visibility,
                                  label: 'View Plans',
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // AI Planner Card
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFAA0000),
                                  width: 2,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      child: Icon(
                                        Icons.flight,
                                        color: const Color(0xFFAA0000),
                                        size: 40,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            'Explore Our AI Powered',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFAA0000),
                                            ),
                                          ),
                                          Text(
                                            'Itinerary Planner!',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFAA0000),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Color(0xFFAA0000),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Ready Itinerary Section
                            const Text(
                              'Explore Ready Itinerary!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFAA0000),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Itinerary cards
                            SizedBox(
                              height: 120,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  _buildItineraryCard(),
                                  const SizedBox(width: 12),
                                  _buildItineraryCard(),
                                  const SizedBox(width: 12),
                                  _buildItineraryCard(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Handle logout if needed
          if (index == 3) {
            _showLogoutDialog();
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFAA0000),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Favourites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Support'),
        ],
      ),
    );
  }

  Widget _buildMenuOption({required IconData icon, required String label}) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildItineraryCard() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // TODO: Add logout logic here
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFAA0000),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
