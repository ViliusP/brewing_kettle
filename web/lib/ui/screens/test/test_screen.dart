import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Weights'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'FontWeight.w100',
            style: TextStyle(fontWeight: FontWeight.w100),
          ),
          Text(
            'FontWeight.w200',
            style: TextStyle(fontWeight: FontWeight.w200),
          ),
          Text(
            'FontWeight.w300',
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
          Text(
            'FontWeight.w400',
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          Text(
            'FontWeight.w500',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            'FontWeight.w600',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            'FontWeight.w700',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            'FontWeight.w800',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          Text(
            'FontWeight.w900',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          Divider(),
          Text(
            'FontWght 100',
            style: TextStyle(
                fontWeight: FontWeight.w100,
                fontVariations: [FontVariation('wght', 100)]),
          ),
          Text(
            'FontWght 200',
            style: TextStyle(
                fontWeight: FontWeight.w200,
                fontVariations: [FontVariation('wght', 200)]),
          ),
          Text(
            'FontWght 300',
            style: TextStyle(
                fontWeight: FontWeight.w300,
                fontVariations: [FontVariation('wght', 300)]),
          ),
          Text(
            'FontWght 400',
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontVariations: [FontVariation('wght', 400)]),
          ),
          Text(
            'FontWght 500',
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontVariations: [FontVariation('wght', 500)]),
          ),
          Text(
            'FontWght 600',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontVariations: [FontVariation('wght', 600)]),
          ),
          Text(
            'FontWght 700',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontVariations: [FontVariation('wght', 700)]),
          ),
          Text(
            'FontWght 800',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontVariations: [FontVariation('wght', 800)]),
          ),
          Text(
            'FontWght 900',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontVariations: [FontVariation('wght', 900)]),
          ),
        ],
      ),
    );
  }
}
