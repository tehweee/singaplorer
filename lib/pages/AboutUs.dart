import 'package:flutter/material.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  int? expandedTileIndex;

  final List<String> images = [
    'https://static.wikia.nocookie.net/fategrandorder/images/3/3b/S386_Stage1.webp/revision/latest?cb=20230811151030',
    'https://static.wikia.nocookie.net/fategrandorder/images/5/58/S386_Stage2.webp/revision/latest?cb=20230811151032',
    'https://static.wikia.nocookie.net/fategrandorder/images/7/73/S386_Stage3.webp/revision/latest?cb=20230811151037',
  ];

  final List<String> titles = ["Why We Made The App", "System Specifications"];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "About Singaplorer",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: screenSize.height * 0.35,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                final positions = [
                  Offset(45, height * 0.1),
                  Offset(width - 195, height * 0.1),
                  Offset(width / 2 - 75, height * 0.35),
                ];

                return Stack(
                  children: List.generate(images.length, (index) {
                    return Positioned(
                      left: positions[index].dx,
                      top: positions[index].dy,
                      width: 150,
                      height: 150,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(images[index]),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 10),
                          ],
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          Expanded(
            child: ListView(
              children: List.generate(titles.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      key: ValueKey(
                        expandedTileIndex == index,
                      ), // change key when expanded state changes
                      title: Text(titles[index]),
                      initiallyExpanded: expandedTileIndex == index,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          expandedTileIndex = expanded ? index : null;
                        });
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(titles[index]),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          // Circles container with dynamic positions, no expand on tap
        ],
      ),
    );
  }
}
