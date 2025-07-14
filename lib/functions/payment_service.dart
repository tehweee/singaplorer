import 'package:flutter_stripe/flutter_stripe.dart';
import 'stripe_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum PaymentResult { success, cancelled, failed, unknownError }

Future<PaymentResult> makePayment([String? priceIDparse]) async {
  try {
    //  Fetch Payment Intent Client Secret from backend
    final url = Uri.parse('http://10.0.2.2:3000/create-payment-intent');

    String? priceId = priceIDparse;

    priceId ??= priceAIToken; // Replace with price ID

    // Call backend to create a payment intent with the price ID
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'priceId': priceId}),
    );

    final jsonResponse = jsonDecode(response.body);
    final clientSecret = jsonResponse['clientSecret'];

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Singaplorer',
        ),
      );
    } catch (e) {
      print('Error during payment sheet: $e');
    }

    // Display Payment Sheet
    try {
      await Stripe.instance.presentPaymentSheet();
      print('Payment successful!');

      return PaymentResult.success;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        print('Payment cancelled by user.');

        return PaymentResult.cancelled;
      } else {
        print('Stripe error: ${e.error.localizedMessage}');

        return PaymentResult.failed;
      }
    }
  } catch (e) {
    print('Unknown error: $e');

    return PaymentResult.unknownError;
  }
}
