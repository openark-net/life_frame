import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'shapes.dart';

class ShapesShowcase extends StatelessWidget {
  const ShapesShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Shapes Showcase'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShapeSection('ZigZag Shapes', _buildZigZagShapes()),
              const SizedBox(height: 32),
              _buildShapeSection('Circle Shapes', _buildCircleShapes()),
              const SizedBox(height: 32),
              _buildShapeSection('Triangle Shapes', _buildTriangleShapes()),
              const SizedBox(height: 32),
              _buildShapeSection('Straight Line Shapes', _buildStraightLineShapes()),
              const SizedBox(height: 32),
              _buildShapeSection('Square Shapes', _buildSquareShapes()),
              const SizedBox(height: 32),
              _buildShapeSection('Squiggly Line Shapes', _buildSquigglyLineShapes()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShapeSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildZigZagShapes() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        const ZigZagShape(),
        const ZigZagShape(
          color: Color(0xFFFF6B6B),
          rotation: math.pi / 4,
        ),
        const ZigZagShape(
          color: Color(0xFF4ECDC4),
          segments: 5,
          lineWidth: 12,
        ),
        const ZigZagShape(
          color: Color(0xFF45B7D1),
          opacity: 0.6,
          width: 120,
        ),
      ],
    );
  }

  Widget _buildCircleShapes() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        const CircleShape(),
        const CircleShape(
          size: 80,
          color: Color(0xFFFF6B6B),
        ),
        const CircleShape(
          color: Color(0xFF4ECDC4),
          shadowOffset: 8,
        ),
        const CircleShape(
          color: Color(0xFF45B7D1),
          opacity: 0.5,
          size: 100,
        ),
      ],
    );
  }

  Widget _buildTriangleShapes() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        const TriangleShape(),
        const TriangleShape(
          size: 80,
          color: Color(0xFFFF6B6B),
          rotation: math.pi / 6,
        ),
        const TriangleShape(
          color: Color(0xFF4ECDC4),
          cornerRadius: 16,
        ),
        const TriangleShape(
          color: Color(0xFF45B7D1),
          opacity: 0.7,
          rotation: -math.pi / 4,
        ),
      ],
    );
  }

  Widget _buildStraightLineShapes() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        const StraightLineShape(),
        const StraightLineShape(
          width: 120,
          height: 20,
          color: Color(0xFFFF6B6B),
          rotation: math.pi / 6,
        ),
        const StraightLineShape(
          color: Color(0xFF4ECDC4),
          width: 60,
          height: 24,
        ),
        const StraightLineShape(
          color: Color(0xFF45B7D1),
          opacity: 0.6,
          rotation: -math.pi / 8,
        ),
      ],
    );
  }

  Widget _buildSquareShapes() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        const SquareShape(),
        const SquareShape(
          size: 80,
          color: Color(0xFFFF6B6B),
          rotation: math.pi / 4,
        ),
        const SquareShape(
          color: Color(0xFF4ECDC4),
          cornerRadius: 20,
        ),
        const SquareShape(
          color: Color(0xFF45B7D1),
          opacity: 0.5,
          size: 100,
          cornerRadius: 4,
        ),
      ],
    );
  }

  Widget _buildSquigglyLineShapes() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        const SquigglyLineShape(),
        const SquigglyLineShape(
          width: 120,
          color: Color(0xFFFF6B6B),
          waves: 4,
          rotation: math.pi / 6,
        ),
        const SquigglyLineShape(
          color: Color(0xFF4ECDC4),
          lineWidth: 12,
          waves: 2,
        ),
        const SquigglyLineShape(
          color: Color(0xFF45B7D1),
          opacity: 0.6,
          width: 140,
          height: 30,
          waves: 5,
        ),
      ],
    );
  }
}