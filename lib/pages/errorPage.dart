import 'package:flutter/material.dart';
import 'package:nct/pages/basePage.dart';
import 'package:go_router/go_router.dart';

class ErrorPage extends StatelessWidget {
  final String error;

  const ErrorPage({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Error',
      children: [
        Text('Error: $error', style: TextStyle(color: Colors.red)),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => context.go('/dashboard'),
          child: Text('Go to Dashboard'),
        ),
      ],
    );
  }
}
