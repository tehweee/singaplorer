import 'package:flutter/material.dart';
import 'package:profile_test_isp/pages/AIChatPage.dart';
import 'package:profile_test_isp/pages/ItineraryPage.dart';
import 'package:profile_test_isp/pages/ProfilePage.dart';
import 'pages/LoadingPage.dart';
import 'consts.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() {
  Gemini.init(apiKey: GEMINI_API_KEY);
  runApp(MaterialApp(
    home: AIChatPage(),
  ));
}
