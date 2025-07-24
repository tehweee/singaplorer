import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:profile_test_isp/pages/SummaryPage.dart';

import 'AIChatPage.dart';
import 'DepartureFlightPage.dart';
import 'AboutUs.dart';
import 'ManualPlanPage.dart';
import 'ProfilePage.dart'; // Assuming this is your ProfilePage

// Re-using ChatUser and ChatMessage classes for consistency
class ChatUser {
  final String id;
  final String firstName;

  ChatUser({required this.id, required this.firstName});
}

class ChatMessage {
  final ChatUser user;
  final String text;
  final DateTime createdAt;
  bool isFavorite;
  final bool isInitialQuestion;

  ChatMessage({
    required this.user,
    required this.text,
    required this.createdAt,
    this.isFavorite = false,
    this.isInitialQuestion = false,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _username = 'Explorer';
  bool _isLoading = true;
  int _currentIndex = 0;
  DateTime? _lastBackPressed;

  // AI Chat integration variables for HomePage
  int _questionIndex = 0;
  final List<String> _questions = [
    "Which category would you like to choose? (Adventure, Chill, Fun)",
    "How many people will be travelling?",
    "What is your budget? (per person)",
    "How long do you want to go for the trip? (in days)",
    "Is there anything you'd like to learn or get from Singapore?",
  ];
  final Map<String, String> _collectedAnswers = {};
  final TextEditingController _homePageTextController = TextEditingController();
  List<ChatMessage> _homePageMessages = [];
  bool _allQuestionsAnswered = false;

  ChatUser _homePageCurrentUser = ChatUser(id: "0", firstName: "User");
  ChatUser _homePageGeminiUser = ChatUser(id: "1", firstName: "AI");

  // Itinerary data to be displayed
  Map<String, dynamic>? _userItinerary;

  @override
  void initState() {
    super.initState();

    // Simulate fetching itinerary data
    _fetchItineraryData();

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _askNextQuestionOnHome();
      });
    });
  }

  void _fetchItineraryData() {
    // This is hardcoded data based on image_7f8f91.png
    _userItinerary = {
      'hotel': {
        'name': 'ST Signature Jalan Besar',
        'address': '15 Upper Weld Road',
        'city': 'Singapore',
        'check_in': 'Aug 5, 2025',
        'check_out': 'Aug 6, 2025',
        'review_score': '7.5 / 155',
        'total_price': '\$99.55',
        'latitude': 1.3054621,
        'longitude': 103.8548538,
      },
      'attractions': [
        {
          'name': 'Admission to Universal Studios Singapore',
          'address': 'Resorts World Sentosa, 8 Sentosa Gateway, Sentosa Island',
          'booked_date': 'Jul 30, 2025 16:00',
          'price_per_pax': '\$82.92',
          'description':
              'With this ticket, you\'ll gain entry into Universal Studios Singapore - a world-class theme park feat...',
          'latitude': 1.255064,
          'longitude': 103.824072,
        },
      ],
    };
  }

  @override
  void dispose() {
    _homePageTextController.dispose();
    super.dispose();
  }

  void _askNextQuestionOnHome() {
    if (_questionIndex < _questions.length) {
      final question = _questions[_questionIndex];
      final msg = ChatMessage(
        user: _homePageGeminiUser,
        text: question,
        createdAt: DateTime.now(),
        isInitialQuestion: true,
      );
      setState(() {
        _homePageMessages.insert(0, msg);
      });
    } else {
      setState(() {
        _allQuestionsAnswered = true;
      });
    }
  }

  void _sendMessageOnHome(String text) {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      user: _homePageCurrentUser,
      text: text.trim(),
      createdAt: DateTime.now(),
    );

    setState(() {
      _homePageMessages.insert(0, userMsg);
    });

    _homePageTextController.clear();

    if (_questionIndex < _questions.length) {
      _collectedAnswers[_questions[_questionIndex]] = text.trim();
      _questionIndex++;
      Future.delayed(const Duration(milliseconds: 300), _askNextQuestionOnHome);
    }
  }

  Widget _buildHomePageMessage(ChatMessage message) {
    final isAI = message.user.id == _homePageGeminiUser.id;

    return Align(
      alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isAI ? Colors.grey[200] : Colors.blue[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: isAI ? MarkdownBody(data: message.text) : Text(message.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;

        final now = DateTime.now();
        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true, // Crucial for keyboard handling
        backgroundColor: Colors.white,
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFAA0000)),
              )
            : SafeArea(
                top: false,
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
                          const SizedBox(height: 30),

                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfileScreen(),
                                    ),
                                  );
                                },
                                child: Container(
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
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),
                          const SizedBox(height: 16),
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
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    // White curved section
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFAA0000),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: SingleChildScrollView(
                            // Make the content scrollable
                            padding: EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              top: 16.0,
                              // Only apply keyboard padding if we don't have a fixed height for chat,
                              // or if there's other content below it that needs to be lifted.
                              // For this setup with fixed chat height, it's less critical here
                              // but good practice if other elements are added directly below.
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),

                                // Menu options
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildMenuOption(
                                      icon: Icons.flight_takeoff,
                                      label: 'Plan Now',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DepartureFlightPage(),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildMenuOption(
                                      icon: Icons.auto_awesome,
                                      label: 'AI Plan',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AIChatPage(),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildMenuOption(
                                      icon: Icons.list_alt,
                                      label: 'View AI Plan',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SummaryAiChatPage(),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildMenuOption(
                                      icon: Icons.visibility,
                                      label: 'View Plans',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ManualPlanPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // AI Chat Section on Homepage
                                // Use a fixed height for the chatbox
                                SizedBox(
                                  height:
                                      300, // Adjusted height for chatbox (approx. 3 times original short size)
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors
                                              .grey[100], // Light grey background
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              // Allows message list to scroll within its area
                                              child: ListView.builder(
                                                reverse: true,
                                                itemCount:
                                                    _homePageMessages.length,
                                                itemBuilder: (context, index) {
                                                  return _buildHomePageMessage(
                                                    _homePageMessages[index],
                                                  );
                                                },
                                              ),
                                            ),
                                            if (!_allQuestionsAnswered)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextField(
                                                        controller:
                                                            _homePageTextController,
                                                        decoration: const InputDecoration(
                                                          hintText:
                                                              "Type your answer...",
                                                          border:
                                                              OutlineInputBorder(),
                                                          contentPadding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 12,
                                                                vertical: 8,
                                                              ),
                                                        ),
                                                        onSubmitted: (text) =>
                                                            _sendMessageOnHome(
                                                              text,
                                                            ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.send,
                                                      ),
                                                      onPressed: () =>
                                                          _sendMessageOnHome(
                                                            _homePageTextController
                                                                .text,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (_allQuestionsAnswered)
                                        Positioned.fill(
                                          child: Container(
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ), // Blurring effect
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Text(
                                                    'All questions answered!',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFFAA0000),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              AIChatPage(
                                                                initialAnswers:
                                                                    _collectedAnswers,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                            0xFFAA0000,
                                                          ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 20,
                                                            vertical: 12,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Click here to use feature',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
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

                                const SizedBox(
                                  height: 24,
                                ), // Space below the chatbox
                                // Itinerary content below the chatbox
                                const Text(
                                  'Your Itinerary',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFAA0000),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (_userItinerary != null)
                                  _buildItineraryCard(_userItinerary!),
                                const SizedBox(height: 20),
                              ],
                            ),
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

            switch (index) {
              case 0:
                // Stay on home
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutUsPage()),
                );
                break;
              case 2:
                // TODO: Navigate to Favourites page
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Favourites coming soon!")),
                );
                break;
              case 3:
                _showLogoutDialog(); // or replace with Support later
                break;
            }
          },

          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFFAA0000),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          showSelectedLabels: false,
          showUnselectedLabels: false,
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
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 70, // Slightly larger width
            height: 70, // Slightly larger height
            decoration: BoxDecoration(
              color: Colors.white, // White background
              borderRadius: BorderRadius.circular(12), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Icon(
              icon,
              color: const Color(0xFFAA0000), // Red icon color
              size: 35, // Larger icon size
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildItineraryCard(Map<String, dynamic> itinerary) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Section
            const Row(
              children: [
                Icon(Icons.hotel, color: Color(0xFFAA0000)),
                SizedBox(width: 8),
                Text(
                  'Hotel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFAA0000),
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildItineraryDetail('Name', itinerary['hotel']['name']),
            _buildItineraryDetail('Address', itinerary['hotel']['address']),
            _buildItineraryDetail('City', itinerary['hotel']['city']),
            _buildItineraryDetail('Check-in', itinerary['hotel']['check_in']),
            _buildItineraryDetail('Check-out', itinerary['hotel']['check_out']),
            _buildItineraryDetail(
              'Review Score',
              itinerary['hotel']['review_score'],
            ),
            _buildItineraryDetail(
              'Total Price',
              itinerary['hotel']['total_price'],
            ),
            const SizedBox(height: 16),

            // Attractions Section
            const Row(
              children: [
                Icon(Icons.attractions, color: Color(0xFFAA0000)),
                SizedBox(width: 8),
                Text(
                  'Attractions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFAA0000),
                  ),
                ),
              ],
            ),
            const Divider(),
            if (itinerary['attractions'] != null &&
                itinerary['attractions'].isNotEmpty)
              ...itinerary['attractions'].map<Widget>((attraction) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attraction['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      _buildItineraryDetail('Address', attraction['address']),
                      _buildItineraryDetail(
                        'Booked Date',
                        attraction['booked_date'],
                      ),
                      _buildItineraryDetail(
                        'Price per Pax',
                        attraction['price_per_pax'],
                      ),
                      Text(
                        attraction['description'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement view on map functionality
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManualPlanPage()),
                  );
                },
                icon: const Icon(Icons.visibility, color: Colors.white),
                label: const Text(
                  'View on Itinerary',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAA0000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItineraryDetail(String label, String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
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
