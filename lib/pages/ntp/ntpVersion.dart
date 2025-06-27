import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';

class NtpVersionCard extends StatelessWidget {
  const NtpVersionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NTP Version Card: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ElevatedButton(onPressed: () => {}, child: Text('Version')),
              ElevatedButton(onPressed: () => {}, child: Text('Instance')),
              ElevatedButton(onPressed: () => {}, child: Text('Update')),
            ],
          ),
        ),
      ),
    );
  }
}

class NtpVersionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'NTP',
      description: 'NTP Server Version Info:',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Actions
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [NtpVersionCard()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
