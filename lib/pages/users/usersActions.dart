import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nct/api/SecurityApi.dart';
import 'package:nct/pages/basePage.dart';
import 'package:nct/api/UserApi.dart';
import 'package:nct/custom/custom.dart';
import 'package:provider/provider.dart';

class UsersActionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'User Management',
      description: 'User Actions:',
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
                  children: [UsersActionsCard()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class UsersActionsCard extends StatefulWidget {
  @override
  _UsersActionsCard createState() => _UsersActionsCard();
}

class _UsersActionsCard extends State<UsersActionsCard> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SecurityApi>().readSecurityPolicy();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SecurityApi>(
      builder: (context, securityApi, _) {
        return Card(
          child: Container(
            //height: 400,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),

                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<SecurityApi>().readSecurityPolicy();

                      _showPasswordSecuityDialog(securityApi.securityPolicy);
                    },
                    child: Text('Security Policy'),
                  ),
                ),
                SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showChangeMyPasswordDialog(),
                    child: Text('Change My Password'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotImplemented() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Not implemented yet')));
  }

  void _showPasswordSecuityDialog(SecurityPolicy policy) {
    final minLenCtrl = TextEditingController(text: policy.MinimumLength);
    final minAgeCtrl = TextEditingController(text: policy.MinimumAge);
    final maxAgeCtrl = TextEditingController(text: policy.MaximumAge);
    final warnAgeCtrl = TextEditingController(text: policy.ExpirationWarning);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SecurityApi>(
          builder: (context, securityApi, _) {
            return AlertDialog(
              title: Text('Password Security'),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LabeledText(
                      myGap: 300,
                      label: "Minimum Length",
                      controller: minLenCtrl,
                      onSubmitted: (value) {
                        policy.MinimumLength = value;
                        securityApi.editSecurityPolicy(policy);
                      },
                    ),
                    LabeledSwitch(
                      myGap: 295,
                      label: "Require Uppercase Character",
                      value: policy.RequireUpper == "true",
                      onChanged: (value) {
                        policy.RequireUpper = value ? "true" : "false";
                        securityApi.editSecurityPolicy(policy);
                      },
                    ),

                    LabeledSwitch(
                      myGap: 295,
                      label: "Require Lowercase Character",
                      value: policy.RequireLower == "true",
                      onChanged: (value) {
                        policy.RequireLower = value ? "true" : "false";
                        securityApi.editSecurityPolicy(policy);
                      },
                    ),

                    LabeledSwitch(
                      myGap: 295,
                      label: "Require at least one numeral",
                      value: policy.RequireNumber == "true",
                      onChanged: (value) {
                        policy.RequireNumber = value ? "true" : "false";
                        securityApi.editSecurityPolicy(policy);
                      },
                    ),

                    LabeledSwitch(
                      myGap: 295,
                      label: "Require special character",
                      value: policy.RequireSpecial == "true",
                      onChanged: (value) {
                        policy.RequireSpecial = value ? "true" : "false";
                        securityApi.editSecurityPolicy(policy);
                      },
                    ),

                    LabeledSwitch(
                      myGap: 295,
                      label: "Doesn't Match Username",
                      value: policy.RequireNoUser == "true",
                      onChanged: (value) {
                        policy.RequireNoUser = value ? "true" : "false";
                        securityApi.editSecurityPolicy(policy);
                      },
                    ),
                    LabeledText(
                      myGap: 300,
                      label: "Minimum Password Age (Days)",
                      controller: minAgeCtrl,
                      onSubmitted: (value) {
                        policy.MinimumAge = value;
                        securityApi.editSecurityPolicy(policy);
                      },
                    ),
                    LabeledText(
                      myGap: 300,
                      label: "Maximum Password Age (Days)",
                      controller: maxAgeCtrl,
                      onSubmitted: (value) {
                        policy.MaximumAge = value;
                        securityApi.editSecurityPolicy(policy);
                      },
                    ),
                    LabeledText(
                      myGap: 300,
                      label: "Expiration Warning (Days)",
                      controller: warnAgeCtrl,
                      onSubmitted: (value) {
                        policy.ExpirationWarning = value;
                        securityApi.editSecurityPolicy(policy);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    //securityApi.editSecurityPolicy(policy);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Security Updated')));
                  },
                  child: Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangeMyPasswordDialog() {
    final oldPwCtrl = TextEditingController();
    final newPwCtrl1 = TextEditingController();
    final newPwCtrl2 = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SecurityApi>(
          builder: (context, securityApi, _) {
            return AlertDialog(
              title: Text('Password Security'),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HiddenLabeledText(
                      myGap: 300,
                      label: "Old password:",
                      controller: oldPwCtrl,
                      onSubmitted: (value) {
                        //policy.MinimumAge = value;
                        //securityApi.editSecurityPolicy(policy);
                      },
                    ),
                    HiddenLabeledText(
                      myGap: 300,
                      label: "New password:",
                      controller: newPwCtrl1,
                      onSubmitted: (value) {
                        //policy.MaximumAge = value;
                        //securityApi.editSecurityPolicy(policy);
                      },
                    ),
                    HiddenLabeledText(
                      myGap: 300,
                      label: "Confirm password:",
                      controller: newPwCtrl2,
                      onSubmitted: (value) {
                        // policy.ExpirationWarning = value;
                        //securityApi.editSecurityPolicy(policy);
                      },
                    ),
                    SizedBox(height: 10),
                    if (securityApi.response != null)
                      Text(
                        securityApi.response!,
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    //securityApi.editSecurityPolicy(policy);
                    securityApi.editCurrentUserPassword(
                      oldPwCtrl.text,
                      newPwCtrl1.text,
                      newPwCtrl2.text,
                    );
                    if (securityApi.response == null) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Password updated")),
                      );
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
