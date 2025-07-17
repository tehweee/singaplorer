import 'package:flutter/material.dart';

// Assuming widgets/mascot_character.dart is in the same directory for this single file example,
// or you'd import it like: import 'package:your_app_name/widgets/mascot_character.dart';

// Your provided MascotCharacter widget (ensure it's in a file named mascot_character.dart
// or within this file for a self-contained example)
class MascotCharacter extends StatelessWidget {
  final double size;
  final BoxFit fit;

  const MascotCharacter({
    super.key,
    this.size = 120,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.1),
        child: Image.asset(
          'assets/images/mascot.png', // Updated path
          width: size,
          height: size,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            // Fallback widget if image fails to load
            return _buildFallbackMascot();
          },
        ),
      ),
    );
  }

  Widget _buildFallbackMascot() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFD32F2F),
        borderRadius: BorderRadius.circular(size * 0.1),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Icon(Icons.explore, size: size * 0.6, color: Colors.white),
    );
  }
}

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  int _selectedIndex =
      1; // For the bottom navigation bar, 'About' is at index 1

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // In a real app, you'd navigate to different pages here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background red shape using CustomArcClipper
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: CustomArcClipper(),
              child: Container(
                height: 200,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF8B0000), // Darker red
                      Color(0xFFB22222), // Lighter red
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 150.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  // Added back button
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    // Handle back button press, e.g., Navigator.pop(context);
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(color: Colors.transparent),
                  titlePadding: const EdgeInsets.only(
                    left: 16.0,
                    bottom: 16.0,
                    right: 16.0,
                  ), // Added right padding
                  centerTitle: true, // Center the title
                  title: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center the row horizontally
                    mainAxisSize: MainAxisSize.min, // Keep row compact
                    children: [
                      const Text(
                        'About Singaplorer',
                        style: TextStyle(
                          color: Colors.white, // Changed to white
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      // Replaced Image.network with MascotCharacter
                      MascotCharacter(
                        size:
                            36.0, // Adjust size as needed to match previous icon size
                        fit: BoxFit
                            .contain, // Use BoxFit.contain or BoxFit.cover as appropriate
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16.0),
                        const Text(
                          '[Motto]',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        _buildExpansionTile(
                          context,
                          title: 'Reason for making app',
                          content:
                              'This app is a collaborative effort with the School of Business to create an intuitive and comprehensive platform for planning trips in Singapore, specifically designed from a foreigner\'s perspective to ease navigation and planning.',
                        ),
                        const SizedBox(height: 16.0),
                        _buildExpansionTile(
                          context,
                          title: 'System Specifications',
                          content:
                              'Singaplorer integrates AI-powered recommendations for personalized trip planning, offers seamless and easy booking functionalities for attractions and accommodations, and provides detailed descriptions and interactive maps for a hassle-free exploration experience.',
                        ),
                        const SizedBox(height: 30.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCircularTeamSection('SEG Team'),
                            _buildCircularTeamSection('SBM Team'),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        Center(child: _buildCircularTeamSection('Together')),
                        const SizedBox(height: 100.0),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(content, style: const TextStyle(fontSize: 14.0)),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularTeamSection(String text) {
    return Container(
      width: 120.0,
      height: 120.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blueGrey[900], // Dark blue color
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class CustomArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
