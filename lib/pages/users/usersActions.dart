import 'package:flutter/material.dart';
import 'package:nct/api/SecurityApi.dart';
import 'package:nct/pages/basePage.dart';
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

                      _showPasswordSecuityDialog(securityApi.securityPolicy!);
                    },
                    child: Text('Security Policy'),
                  ),
                ),
                SizedBox(height: 8),

                //SizedBox(
                //  width: double.infinity,
                //  child: ElevatedButton(
                //    onPressed: () => _showChangeMyPasswordDialog(),
                //    child: Text('Change My Password'),
                //  ),
                //),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPasswordSecuityDialog(SecurityPolicy policy) {
    final minLenCtrl = TextEditingController(
      text: policy.MinimumLength.toString(),
    );
    final minAgeCtrl = TextEditingController(
      text: policy.MinimumAge.toString(),
    );
    final maxAgeCtrl = TextEditingController(
      text: policy.MaximumAge.toString(),
    );
    final warnAgeCtrl = TextEditingController(
      text: policy.ExpirationWarning.toString(),
    );

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
                        policy.MinimumLength = int.parse(value);
                        securityApi.editSecurityPolicy(policy);
                      },
                    ),
                    LabeledSwitch(
                      myGap: 295,
                      label: "Require Uppercase Character",
                      value: policy.RequireUpper,
                      onChanged: (value) {
                        policy.RequireUpper = value;
                        securityApi.editSecurityPolicy(policy);
                      },
                    ),

                    LabeledSwitch(
                      myGap: 295,
                      label: "Require Lowercase Character",
                      value: policy.RequireLower,
                      onChanged: (value) {
                        policy.RequireLower = value;
                        securityApi.editSecurityPolicy(policy);
                      },
                    ),

                    LabeledSwitch(
                      myGap: 295,
                      label: "Require at least one numeral",
                      value: policy.RequireNumber,
                      onChanged: (value) {
                        policy.RequireNumber = value;
                        securityApi.editSecurityPolicy(policy);
                      },
                    ),

                    LabeledSwitch(
                      myGap: 295,
                      label: "Require special character",
                      value: policy.RequireSpecial,
                      onChanged: (value) {
                        policy.RequireSpecial = value;
                        securityApi.editSecurityPolicy(policy);
                      },
                    ),

                    LabeledSwitch(
                      myGap: 295,
                      label: "Doesn't Match Username",
                      value: policy.RequireNoUser,
                      onChanged: (value) {
                        policy.RequireNoUser = value;
                        securityApi.editSecurityPolicy(policy);
                      },
                    ),
                    LabeledText(
                      myGap: 300,
                      label: "Minimum Password Age (Days)",
                      controller: minAgeCtrl,
                      onSubmitted: (value) {
                        policy.MinimumAge = int.parse(value);
                        securityApi.editSecurityPolicy(policy);
                      },
                    ),
                    LabeledText(
                      myGap: 300,
                      label: "Maximum Password Age (Days)",
                      controller: maxAgeCtrl,
                      onSubmitted: (value) {
                        policy.MaximumAge = int.parse(value);
                        securityApi.editSecurityPolicy(policy);
                      },
                    ),
                    LabeledText(
                      myGap: 300,
                      label: "Expiration Warning (Days)",
                      controller: warnAgeCtrl,
                      onSubmitted: (value) {
                        policy.ExpirationWarning = int.parse(value);
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
}
