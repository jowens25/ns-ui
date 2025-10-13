import 'package:flutter/material.dart';
import 'package:nct/custom/custom.dart';
import 'package:nct/api/NetworkApi.dart';
import 'package:provider/provider.dart';

class NetworkProtocolsCard extends StatefulWidget {
  const NetworkProtocolsCard({super.key});

  @override
  State<NetworkProtocolsCard> createState() => _NetworkProtocolsCard();
}

class _NetworkProtocolsCard extends State<NetworkProtocolsCard> {
  @override
  void initState() {
    super.initState();
    context.read<NetworkApi>().readTelnetInfo();
    context.read<NetworkApi>().readSshInfo();
    context.read<NetworkApi>().readHttpInfo();
    context.read<NetworkApi>().readFtpInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkApi>(
      builder: (context, networkApi, _) {
        return Card(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Protocols:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        tooltip: "Info",
                        onPressed: showProtocolInfo,
                      ),
                    ],
                  ),

                  LabeledSwitch(
                    myGap: 250,
                    label: "Telnet",
                    value: networkApi.telnet.Status == "active",
                    onChanged: (bool value) {
                      setState(() {
                        networkApi.telnet.Action = value ? "start" : "stop";
                        networkApi.editTelnetInfo(networkApi.telnet);
                      });
                    },
                  ),
                  LabeledSwitch(
                    myGap: 250,
                    label: "SSH + SFTP",
                    value: networkApi.ssh.Status == "active",
                    onChanged: (bool value) {
                      setState(() {
                        networkApi.ssh.Action = value ? "start" : "stop";
                        networkApi.editSshInfo(networkApi.ssh);
                      });
                    },
                  ),
                  LabeledSwitch(
                    myGap: 250,
                    label: "FTP",
                    value: networkApi.ftp.Status == "active",
                    onChanged: (bool value) {
                      setState(() {
                        networkApi.ftp.Action = value ? "start" : "stop";
                        networkApi.editFtpInfo(networkApi.ftp);
                      });
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

  void showProtocolInfo() {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text("Protocols"),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text("Enable or disable insecure protocols")],
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
}
