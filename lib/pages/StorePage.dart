import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../functions/payment_service.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  List<dynamic> products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/products'));

    if (response.statusCode == 200) {
      setState(() {
        products = jsonDecode(response.body);
        loading = false;
      });
    } else {
      setState(() => loading = false);
      print('Error fetching products: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Store')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final priceList = product['prices'] as List<dynamic>;

                return ListTile(
                  title: Text(product['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: priceList.map((price) {
                      final amount = (price['unit_amount'] ?? 0) / 100;
                      final currency = price['currency']
                          .toString()
                          .toUpperCase();
                      return Text('$amount $currency');
                    }).toList(),
                  ),
                  onTap: () {
                    if (priceList.isNotEmpty) {
                      final priceId = priceList
                          .first['id']; // Choose the first price by default
                      makePayment(priceId); // Or makePayment() if optional
                    } else {
                      print('No price available for this product');
                    }
                  },
                );
              },
            ),
    );
  }
}
