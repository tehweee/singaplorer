import 'package:flutter/material.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController helpController = TextEditingController();

  String? selectedCountry;
  List<String> countries = ['USA', 'Singapore', 'Canada', 'UK'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Set this to true
      backgroundColor: const Color(0xFFEDEDED),
      body: SingleChildScrollView(
        // This allows the content to scroll
        child: Column(
          children: [
            Stack(
              children: [
                // Red curved header layers
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(color: Color(0xFF800000)),
                  ),
                ),

                // Middle curve
                Positioned(
                  top: 30,
                  right: 0,
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.875,
                    decoration: const BoxDecoration(
                      color: Color(0xFF990000),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(90),
                      ),
                    ),
                  ),
                ),

                // Top-most bright red curve
                Positioned(
                  top: 50,
                  right: 0,
                  child: Container(
                    height: 30,
                    width: MediaQuery.of(context).size.width * 0.75,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB30000),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(80),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mascot and speech bubble
                      Row(
                        children: [
                          // Make sure 'images/mascot.png' exists in your assets and pubspec.yaml
                          Image.asset(
                            'images/mascot.png',
                            width: 50,
                            height: 50,
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'What can we help you with today?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Text("First Name:"),
                      const SizedBox(height: 5),
                      TextField(
                        controller: firstNameController,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFD9D9D9),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),

                      const Text("Last Name:"),
                      const SizedBox(height: 5),
                      TextField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFD9D9D9),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),

                      const Text("Country:"),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          border: Border.all(),
                        ),
                        child: DropdownButton<String>(
                          value: selectedCountry,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.brown,
                          ),
                          underline: const SizedBox(),
                          items: countries.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCountry = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 15),

                      const Text("What can we help you with:"),
                      const SizedBox(height: 5),
                      TextField(
                        controller: helpController,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFD9D9D9),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 30),

                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003C5F),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            print('Ticket Sent!');
                            // You might want to add logic here to actually send the ticket
                            // e.g., using a backend service or showing a confirmation dialog.
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Send Ticket',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
