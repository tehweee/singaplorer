import 'package:flutter/material.dart';
import 'package:profile_test_isp/pages/AIChatPage.dart';
import 'package:profile_test_isp/pages/ArrivalFlightPage.dart';
import 'package:profile_test_isp/pages/HotelPage.dart';
import 'package:profile_test_isp/pages/ItineraryPage.dart';
import 'package:profile_test_isp/pages/ProfilePage.dart';
import 'package:profile_test_isp/pages/StorePage.dart';
import 'pages/LoadingPage.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'functions/stripe_constants.dart';
import 'consts.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'pages/HomePage.dart';
import 'pages/DepartureFlightPage.dart';
import 'pages/StartPage.dart';
import 'pages/AboutUs.dart';
import 'pages/AboutPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = apiKey;

  await Stripe.instance.applySettings();
  Gemini.init(apiKey: GEMINI_API_KEY);
  runApp(MaterialApp(home: StartPage()));
}
