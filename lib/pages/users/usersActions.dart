import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';
import 'package:ntsc_ui/api/UserApi.dart';
import 'package:ntsc_ui/pages/snmp/snmpStatus.dart';
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userApi = context.read<UserApi>();
      userApi.readUsers();
      _searchController.addListener(() {
        userApi.searchUsers(_searchController.text);
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: () => _showPasswordSecuityDialog(),
                child: Text('Security Policy'),
              ),
            ),
            SizedBox(height: 8),
            //SizedBox(
            //  width: double.infinity,
            //  child: ElevatedButton(
            //    onPressed: () => _showNotImplemented(),
            //    child: Text('LDAP Setup'),
            //  ),
            //),
            //SizedBox(height: 8),
            //SizedBox(
            //  width: double.infinity,
            //  child: ElevatedButton(
            //    onPressed: () => _showNotImplemented(),
            //    child: Text('RADIUS Setup'),
            //  ),
            //),
            //SizedBox(height: 8),
            //SizedBox(
            //  width: double.infinity,
            //  child: ElevatedButton(
            //    onPressed: () => _showNotImplemented(),
            //    child: Text('TACACS+ Setup'),
            //  ),
            //),
            //SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showNotImplemented(),
                child: Text('Change My Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotImplemented() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Not implemented yet')));
  }

  //  Widget _buildUsersList() {
  //    return Consumer<UserApi>(
  //      builder: (context, userApi, _) {
  //        if (userApi.filteredUsers.isEmpty) {
  //          return Center(
  //            child: Text(
  //              'No users found',
  //              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
  //            ),
  //          );
  //        }
  //
  //        return ListView.builder(
  //          itemCount: userApi.filteredUsers.length,
  //          itemBuilder: (context, index) {
  //            final user = userApi.filteredUsers[index];
  //            return Card(
  //              margin: EdgeInsets.only(bottom: 8),
  //              child: ListTile(
  //                leading: CircleAvatar(
  //                  child: Text(
  //                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
  //                  ),
  //                ),
  //                title: Text('${user.name} - ${user.role}'),
  //                subtitle: Text(user.email),
  //
  //                trailing: PopupMenuButton<String>(
  //                  onSelected: (value) {
  //                    if (value == 'delete') {
  //                      _showDeleteUserDialog(user);
  //                    }
  //                    if (value == 'edit') {
  //                      _showEditUserDialog(user);
  //                    }
  //                  },
  //                  itemBuilder:
  //                      (context) => [
  //                        PopupMenuItem(
  //                          value: 'edit',
  //                          child: Row(
  //                            children: [
  //                              Icon(Icons.edit, size: 16),
  //                              SizedBox(width: 8),
  //                              Text('Edit'),
  //                            ],
  //                          ),
  //                        ),
  //                        PopupMenuItem(
  //                          value: 'delete',
  //                          child: Row(
  //                            children: [
  //                              Icon(Icons.delete, size: 16, color: Colors.red),
  //                              SizedBox(width: 8),
  //                              Text(
  //                                'Delete',
  //                                style: TextStyle(color: Colors.red),
  //                              ),
  //                            ],
  //                          ),
  //                        ),
  //                      ],
  //                ),
  //              ),
  //            );
  //          },
  //        );
  //      },
  //    );
  //  }
  //
  //  void _showAddUserDialog() {
  //    final nameController = TextEditingController();
  //    final emailController = TextEditingController();
  //    final passwordController = TextEditingController();
  //
  //    showDialog(
  //      context: context,
  //      builder: (BuildContext context) {
  //        return Consumer<UserApi>(
  //          builder: (context, userApi, _) {
  //            String selectedRole =
  //                "viewer"; // Add this as a variable in your widget state
  //
  //            return AlertDialog(
  //              title: Text('Add User'),
  //              content: Column(
  //                mainAxisSize: MainAxisSize.min,
  //                children: [
  //                  TextField(
  //                    controller: nameController,
  //                    decoration: InputDecoration(labelText: 'Name'),
  //                  ),
  //
  //                  TextField(
  //                    controller: emailController,
  //                    decoration: InputDecoration(labelText: 'Email'),
  //                  ),
  //                  TextField(
  //                    controller: passwordController,
  //                    obscureText: true,
  //                    decoration: InputDecoration(labelText: 'Password'),
  //                  ),
  //                  SizedBox(height: 16),
  //                  DropdownButtonFormField<String>(
  //                    value: selectedRole,
  //                    decoration: InputDecoration(labelText: 'Role'),
  //                    items: [
  //                      DropdownMenuItem(value: "viewer", child: Text("Viewer")),
  //                      DropdownMenuItem(value: "admin", child: Text("Admin")),
  //                    ],
  //                    onChanged: (String? newValue) {
  //                      setState(() {
  //                        selectedRole = newValue!;
  //                      });
  //                    },
  //                  ),
  //                ],
  //              ),
  //              actions: [
  //                TextButton(
  //                  onPressed: () => Navigator.pop(context),
  //                  child: Text('Cancel'),
  //                ),
  //                ElevatedButton(
  //                  onPressed: () async {
  //                    if (nameController.text.isNotEmpty &&
  //                        emailController.text.isNotEmpty) {
  //                      await userApi.addUser(
  //                        selectedRole,
  //                        nameController.text,
  //                        emailController.text,
  //                        passwordController.text,
  //                      );
  //                      Navigator.pop(context);
  //                      ScaffoldMessenger.of(
  //                        context,
  //                      ).showSnackBar(SnackBar(content: Text('User added')));
  //                    }
  //                  },
  //                  child: Text('Add'),
  //                ),
  //              ],
  //            );
  //          },
  //        );
  //      },
  //    );
  //  }
  //
  //  void _showDeleteUserDialog(User user) {
  //    showDialog(
  //      context: context,
  //      builder: (BuildContext context) {
  //        return Consumer<UserApi>(
  //          builder: (context, userApi, _) {
  //            return AlertDialog(
  //              title: Text('Delete User'),
  //              content: Text('Delete ${user.name}?'),
  //              actions: [
  //                TextButton(
  //                  onPressed: () => Navigator.pop(context),
  //                  child: Text('Cancel'),
  //                ),
  //                TextButton(
  //                  onPressed: () async {
  //                    await userApi.deleteUser(user);
  //                    Navigator.pop(context);
  //                    ScaffoldMessenger.of(context).showSnackBar(
  //                      SnackBar(content: Text(userApi.messageError)),
  //                    );
  //                  },
  //                  child: Text('Delete', style: TextStyle(color: Colors.red)),
  //                ),
  //              ],
  //            );
  //          },
  //        );
  //      },
  //    );
  //  }
  //
  //  void _showEditUserDialog(User user) {
  //    final nameController = TextEditingController();
  //    final emailController = TextEditingController();
  //    final passwordController = TextEditingController();
  //
  //    showDialog(
  //      context: context,
  //      builder: (BuildContext context) {
  //        return Consumer<UserApi>(
  //          builder: (context, userApi, _) {
  //            //
  //            nameController.text = user.name;
  //            emailController.text = user.email;
  //            passwordController.text = 'userpassword';
  //            String selectedRole = user.role;
  //            //String selectedRole = "viewer";
  //
  //            return AlertDialog(
  //              title: Text('Edit User'),
  //              content: Column(
  //                mainAxisSize: MainAxisSize.min,
  //                children: [
  //                  TextField(
  //                    controller: nameController,
  //                    decoration: InputDecoration(labelText: 'Name'),
  //                  ),
  //
  //                  TextField(
  //                    controller: emailController,
  //                    decoration: InputDecoration(labelText: 'Email'),
  //                  ),
  //                  TextField(
  //                    controller: passwordController,
  //                    obscureText: true,
  //                    decoration: InputDecoration(labelText: 'Password'),
  //                  ),
  //                  SizedBox(height: 16),
  //                  DropdownButtonFormField<String>(
  //                    value: selectedRole,
  //                    decoration: InputDecoration(labelText: 'Role'),
  //                    items: [
  //                      DropdownMenuItem(value: "viewer", child: Text("Viewer")),
  //                      DropdownMenuItem(value: "admin", child: Text("Admin")),
  //                    ],
  //                    onChanged: (String? newValue) {
  //                      setState(() {
  //                        selectedRole = newValue!;
  //                      });
  //                    },
  //                  ),
  //                ],
  //              ),
  //              actions: [
  //                TextButton(
  //                  onPressed: () => Navigator.pop(context),
  //                  child: Text('Cancel'),
  //                ),
  //                ElevatedButton(
  //                  onPressed: () async {
  //                    if (nameController.text.isNotEmpty &&
  //                        emailController.text.isNotEmpty) {
  //                      user.name = nameController.text;
  //                      user.email = emailController.text;
  //                      user.password = passwordController.text;
  //                      user.role = selectedRole;
  //                      await userApi.updateUser(user);
  //                      Navigator.pop(context);
  //                      ScaffoldMessenger.of(
  //                        context,
  //                      ).showSnackBar(SnackBar(content: Text('User updated')));
  //                    }
  //                  },
  //                  child: Text('Save'),
  //                ),
  //              ],
  //            );
  //          },
  //        );
  //      },
  //    );
  //  }

  void _showPasswordSecuityDialog() {
    final lengthController = TextEditingController(text: "12");
    final minimumPasswordAgeController = TextEditingController(text: "0");
    final maximumPasswordAgeController = TextEditingController(text: "9999");
    final expirationWarningController = TextEditingController(text: "14");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<UserApi>(
          builder: (context, userApi, _) {
            //
            //ipv4AddressController.text = user.ip4Address;
            //ipv6AddressController.text = user.ip6Address;
            //communityController.text = user.community;
            //String selectedIpVersion = user.ipVersion;
            //String selectedGroup = user.groupName;
            //String selectedSnmpVersion = user.version;

            return AlertDialog(
              title: Text('Password Security'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 300,
                        child: Text(
                          "Minimum Length",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: TextField(
                          //onSubmitted: (value) {
                          //  details.SysContact = value;
                          //  userApi.updateSnmpSysDetails(details);
                          //},
                          controller: lengthController,
                          decoration: InputDecoration(isDense: true),
                        ),
                      ),
                    ],
                  ),

                  LabeledSwitch(
                    label: "Require Uppercase Character:  ",
                    value: true,
                    onChanged: (value) {},
                  ),
                  LabeledSwitch(
                    label: "Require Lowercase Character:  ",
                    value: true,
                    onChanged: (value) {},
                  ),
                  LabeledSwitch(
                    label: "Require at least one numeral: ",
                    value: false,
                    onChanged: (value) {},
                  ),
                  LabeledSwitch(
                    label: "Require Special Character:    ",
                    value: true,
                    onChanged: (value) {},
                  ),
                  LabeledSwitch(
                    label: "Doesn't Match Username:       ",
                    value: false,
                    onChanged: (value) {},
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 300,
                        child: Text(
                          "Minimum Password Age (days)",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: TextField(
                          //onSubmitted: (value) {
                          //  details.SysContact = value;
                          //  userApi.updateSnmpSysDetails(details);
                          //},
                          controller: minimumPasswordAgeController,
                          decoration: InputDecoration(isDense: true),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 300,
                        child: Text(
                          "Maximum Password Age (days)",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: TextField(
                          //onSubmitted: (value) {
                          //  details.SysContact = value;
                          //  userApi.updateSnmpSysDetails(details);
                          //},
                          controller: maximumPasswordAgeController,
                          decoration: InputDecoration(isDense: true),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 300,
                        child: Text(
                          "Expiration Warning (days)",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: TextField(
                          //onSubmitted: (value) {
                          //  details.SysContact = value;
                          //  userApi.updateSnmpSysDetails(details);
                          //},
                          controller: expirationWarningController,
                          decoration: InputDecoration(isDense: true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    //final userApi = context.read<UserApi>();

                    //user.version = selectedSnmpVersion;
                    //user.groupName = selectedGroup;
                    //user.community = communityController.text;
                    //user.ipVersion = selectedIpVersion;
                    //user.ip4Address = ipv4AddressController.text;
                    //user.ip6Address = ipv6AddressController.text;

                    //userApi.updateSnmpV1V2cUser(user);

                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('SNMP User added')));
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
