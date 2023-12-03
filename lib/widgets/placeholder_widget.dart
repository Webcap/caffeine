import 'package:flutter/material.dart';

class PlaceHolderPage extends StatefulWidget {
  const PlaceHolderPage({super.key});

  @override
  _PlaceHolderState createState() => _PlaceHolderState();
}

class _PlaceHolderState extends State<PlaceHolderPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
