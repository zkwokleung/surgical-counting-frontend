import 'package:flutter/material.dart';

class DashCard extends StatefulWidget {
  const DashCard({
    super.key,
    required this.title,
    required this.child,
    this.backgroundColor = Colors.white,
    this.floatingActionButton,
    this.textSize = 16,
    this.titleFontWeight = FontWeight.bold,
  });

  final String title;
  final Widget child;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final double textSize;
  final FontWeight? titleFontWeight;

  @override
  State<DashCard> createState() => _DashCardState();
}

class _DashCardState extends State<DashCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: Scaffold(
        backgroundColor: widget.backgroundColor,
        floatingActionButton: widget.floatingActionButton,
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: widget.textSize,
                    fontWeight: widget.titleFontWeight,
                  ),
                ),
                Expanded(child: Center(child: widget.child)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
