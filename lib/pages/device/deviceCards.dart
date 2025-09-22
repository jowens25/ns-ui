import 'package:flutter/material.dart';
import 'package:nct/pages/basePage.dart';
import 'package:nct/custom/custom.dart';
import 'package:provider/provider.dart';
import 'package:nct/api/DeviceApi.dart';

class DeviceConfigCard extends StatefulWidget {
  @override
  State<DeviceConfigCard> createState() => _DeviceConfigCardState();
}

class _DeviceConfigCardState extends State<DeviceConfigCard> {
  final commandCtrl = TextEditingController();

  /// This will hold a list of "command + response" entries
  final List<_CommandEntry> history = [];

  @override
  void dispose() {
    commandCtrl.dispose();
    super.dispose();
  }

  void _sendCommand(DeviceApi deviceApi, String command) async {
    // Add a temporary entry with "pending" response
    setState(() {
      history.add(_CommandEntry(command: command, response: '...'));
    });

    // Send command and wait for response
    await deviceApi.writeCommand(command);

    // Replace last history entry with updated response
    setState(() {
      history[history.length - 1] =
          _CommandEntry(command: command, response: deviceApi.serialResponse ?? '');
    });

    commandCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceApi>(
      builder: (context, deviceApi, _) {
        return Card(
          child: SizedBox(
            width: double.infinity,
            height: 400, // ✅ Fixed height to make list scrollable
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// Scrollable history of commands + responses
                  Expanded(
                    child: ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final entry = history[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("> ${entry.command}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue)),
                              Text(entry.response,
                                  style: const TextStyle(color: Colors.green)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// Command input at the bottom
                  LabeledText(
                    label: "Command",
                    controller: commandCtrl,
                    myGap: 80,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _sendCommand(deviceApi, value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Helper class to store command + response together
class _CommandEntry {
  final String command;
  final String response;

  _CommandEntry({required this.command, required this.response});
}
