import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';

class NtpUtcConfigCard extends StatelessWidget {
  const NtpUtcConfigCard({super.key});

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
                'NTP UTC Config Card: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ElevatedButton(onPressed: () => {}, child: Text('Leap 59')),
              ElevatedButton(
                onPressed: () => {},
                child: Text('Leap 59 In Progress'),
              ),
              ElevatedButton(onPressed: () => {}, child: Text('Leap 61')),
              ElevatedButton(
                onPressed: () => {},
                child: Text('Leap 61 in Progress'),
              ),
              ElevatedButton(
                onPressed: () => {},
                child: Text('UTC Smearing Enabled'),
              ),
              ElevatedButton(
                onPressed: () => {},
                child: Text('UTC Offset Enabled'),
              ),

              ElevatedButton(
                onPressed: () => {},
                child: Text('UTC Offset Value'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NtpUtcConfigPage extends StatelessWidget {
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
                  children: [NtpUtcConfigCard()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
