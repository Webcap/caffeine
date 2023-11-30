import 'package:flutter/material.dart';

class upgrade_premium_screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Access'),
        backgroundColor: Colors.blue,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Remove all ads, unlock all movies, and download for offline viewing.',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                pricingPlan('Week', '\$1.99'),
                pricingPlan('Month', '\$4.99'),
                pricingPlan('Year', '\$29.99'),
              ],
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Price: \$8.53(41% off)',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Price: \$103.76(71% off)',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'If the ad still appears after purchase, tap Restore',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Subscription Terms',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Payment will be charged to your Google Play account. Your subscription automatically renews unless you cancel the subscription 24-hours before the end of the current period.',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Your account will be charged for renewal at the price listed within 24 hours before the end of the current period. You can manage or unsubscribe at any time in Google Play account settings.',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget pricingPlan(String planName, String price) {
  return Container(
    padding: const EdgeInsets.all(10.0),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.blue),
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Column(
      children: [
        Text(planName,
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5.0),
        Text(price, style: const TextStyle(fontSize: 20.0)),
      ],
    ),
  );
}
