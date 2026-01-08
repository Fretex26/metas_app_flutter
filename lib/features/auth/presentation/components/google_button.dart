import 'package:flutter/material.dart';

class GoogleButton extends StatelessWidget {
  final void Function()? onTap;

  const GoogleButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.tertiary),
        ),
        // child: Text('Sí compila'),
        child: Image.asset(
          'lib/assets/google.png', 
          height: 32,
        ),
      ),
    );
  }
}
