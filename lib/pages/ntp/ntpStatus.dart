import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';

class NtpStatusCard extends StatelessWidget {
  const NtpStatusCard({super.key});

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
                'NTP Status Card: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ElevatedButton(onPressed: () => {}, child: Text('Enable')),
              ElevatedButton(onPressed: () => {}, child: Text('Requests')),

              ElevatedButton(onPressed: () => {}, child: Text('Responses')),
              ElevatedButton(
                onPressed: () => {},
                child: Text('Requests Dropped'),
              ),

              ElevatedButton(onPressed: () => {}, child: Text('Broadcasts')),
              ElevatedButton(
                onPressed: () => {},
                child: Text('Clear Counters'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NtpStatusPage extends StatelessWidget {
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
                  children: [NtpStatusCard()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
