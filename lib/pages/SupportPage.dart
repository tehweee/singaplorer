import 'package:flutter/material.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  // Global key for the form
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController helpController = TextEditingController();

  String? selectedCountry;
  List<String> countries = ['USA', 'Singapore', 'Canada', 'UK'];

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    helpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFEDEDED),
      body: SingleChildScrollView(
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
                  child: Form(
                    // Wrap your form fields in a Form widget
                    key: _formKey, // Assign the global key
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mascot and speech bubble
                        Row(
                          children: [
                            Image.asset(
                              'images/mascot.png', // Ensure this asset is in your pubspec.yaml
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
                        TextFormField(
                          // Use TextFormField for validation
                          controller: firstNameController,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFD9D9D9),
                            border: OutlineInputBorder(),
                            hintText: 'Enter your first name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'First Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        const Text("Last Name:"),
                        const SizedBox(height: 5),
                        TextFormField(
                          // Use TextFormField for validation
                          controller: lastNameController,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFD9D9D9),
                            border: OutlineInputBorder(),
                            hintText: 'Enter your last name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Last Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        const Text("Country:"),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9D9D9),
                            border: Border.all(
                              color: selectedCountry == null
                                  ? Colors.red
                                  : Colors.grey, // Visual feedback for dropdown
                              width: selectedCountry == null ? 2.0 : 1.0,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            // Hide default underline
                            child: DropdownButton<String>(
                              value: selectedCountry,
                              isExpanded: true,
                              hint: const Text(
                                'Select your country',
                              ), // Hint for dropdown
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.brown,
                              ),
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
                        ),
                        // Manually show error for dropdown if not selected
                        if (selectedCountry == null &&
                            _formKey.currentState?.validate() == false)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Country is required',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 15),

                        const Text("What can we help you with:"),
                        const SizedBox(height: 5),
                        TextFormField(
                          // Use TextFormField for validation
                          controller: helpController,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFD9D9D9),
                            border: OutlineInputBorder(),
                            hintText: 'Describe your issue here',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please describe what we can help you with';
                            }
                            return null;
                          },
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
                              // Validate all fields when the button is pressed
                              if (_formKey.currentState!.validate()) {
                                // Check if country is selected separately
                                if (selectedCountry == null) {
                                  setState(() {
                                    // Trigger a rebuild to show the country validation message
                                  });
                                  return;
                                }

                                // If all fields are valid, proceed with sending the ticket
                                print('Ticket Sent!');
                                print(
                                  'First Name: ${firstNameController.text}',
                                );
                                print('Last Name: ${lastNameController.text}');
                                print('Country: $selectedCountry');
                                print(
                                  'Help Description: ${helpController.text}',
                                );

                                // You can add your logic here to send the data
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Processing Data'),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please fill out all required fields',
                                    ),
                                  ),
                                );
                              }
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
