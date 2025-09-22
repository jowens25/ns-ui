import 'package:flutter/material.dart';
import 'package:nct/pages/basePage.dart';
import 'package:nct/custom/custom.dart';
import 'package:provider/provider.dart';
import 'package:nct/api/DeviceApi.dart';

import 'package:flutter/material.dart';
// ... other imports

class DeviceConfigCard extends StatefulWidget {
  @override
  State<DeviceConfigCard> createState() => _DeviceConfigCardState();
}

class _DeviceConfigCardState extends State<DeviceConfigCard> {
  final commandCtrl = TextEditingController();
  final List<_CommandEntry> history = [];

  // ADD: Scroll controller for history list
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    commandCtrl.dispose();
    _scrollController.dispose(); // Dispose the controller!
    super.dispose();
  }

  void _sendCommand(DeviceApi deviceApi, String command) async {
    setState(() {
      history.add(_CommandEntry(command: command, response: '...'));
    });

    // After new entry, scroll to bottom
    _scrollToBottom();

    // Send command
    await deviceApi.writeCommand(command);

    setState(() {
      history[history.length - 1] = _CommandEntry(
        command: command,
        response: deviceApi.serialResponse ?? '',
      );
    });

    _scrollToBottom(); // Scroll again after response updated

    commandCtrl.clear();
  }

  // Helper function
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Show suggested commands in a dialog
  void _showCommandInfo() {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text("Try these commands"),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("help"),
                Text("reset"),
                Text("status"),
                // Add more suggestions as needed
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceApi>(
      builder: (context, deviceApi, _) {
        return Card(
          child: SizedBox(
            width: double.infinity,
            height: 400,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
  
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                       
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          tooltip: "Commands",
                          onPressed: _showCommandInfo,
                        ),
                      ],
                    ),
                  
                  SizedBox(height: 4),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController, // <-- add controller
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final entry = history[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "> ${entry.command}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(entry.response),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
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

// Helper class as before
class _CommandEntry {
  final String command;
  final String response;
  _CommandEntry({required this.command, required this.response});
}
