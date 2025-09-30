import 'package:flutter/material.dart';
import 'package:nct/api/SecurityApi.dart';
import 'package:nct/api/UserApi.dart';
import 'package:provider/provider.dart';
import 'package:nct/custom/custom.dart';

class UsersManagementCard extends StatefulWidget {
  @override
  _UsersManagementCardState createState() => _UsersManagementCardState();
}

class _UsersManagementCardState extends State<UsersManagementCard> {
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userApi = context.read<UserApi>();
      context.read<SecurityApi>().readSecurityPolicy();

      userApi.readUsers();
      _searchController.addListener(() {
        userApi.searchUsers(_searchController.text);
      });
    });

    _searchController.text = '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SecurityApi>(
      builder: (context, securityApi, _) {
        return Card(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Users:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        tooltip: "Info",
                        onPressed: _showInfo,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  Row(
                    children: [
                      SizedBox(
                        width: 300,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search users...',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showAddUserDialog(),
                        icon: Icon(Icons.add),
                        tooltip: 'Add User',
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Users List
                  Container(height: 230, child: _buildUsersList()),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.read<SecurityApi>().readSecurityPolicy();

                          _showPasswordSecuityDialog(
                            securityApi.securityPolicy!,
                          );
                        },
                        child: Text('Security Policy'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsersList() {
    return Consumer<UserApi>(
      builder: (context, userApi, _) {
        if (userApi.filteredUsers.isEmpty) {
          return Center(
            child: Text(
              'No users found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          );
        }

        return ListView.builder(
          itemCount: userApi.filteredUsers.length,
          itemBuilder: (context, index) {
            final user = userApi.filteredUsers[index];
            return Container(
              child: Card(
                color: Colors.grey,
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    ),
                  ),
                  title: Text('${user.name} - ${user.role}'),
                  subtitle: Text(user.email),

                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteUserDialog(user);
                      }
                      if (value == 'edit') {
                        _showEditUserDialog(user);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 16),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 16, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text("User management"),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Add users, remove and configure password policy"),
                Text("Admins - read and write"),
                Text("Viewers - read only"),

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
                      onSubmitted: (value) {},
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
                      onSubmitted: (value) {},
                    ),
                    LabeledText(
                      myGap: 300,
                      label: "Maximum Password Age (Days)",
                      controller: maxAgeCtrl,
                      onSubmitted: (value) {},
                    ),
                    LabeledText(
                      myGap: 300,
                      label: "Expiration Warning (Days)",
                      controller: warnAgeCtrl,
                      onSubmitted: (value) {},
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
                    policy.MinimumLength = int.parse(minLenCtrl.text);

                    await securityApi.editSecurityPolicy(policy);
                    Navigator.pop(context);
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

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    //final emailController = TextEditingController();
    final passwordController = TextEditingController();

    final securityApi = context.read<SecurityApi>();
    SecurityPolicy policy =
        securityApi.securityPolicy!; // Use the getter instead

    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool _obscurePassword = true; // initially obscure

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Consumer<UserApi>(
              builder: (context, userApi, _) {
                String selectedRole = "admin";

                return AlertDialog(
                  title: Text('Add User'),
                  content: SizedBox(
                    width: 400,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(labelText: 'Name'),
                        ),

                        // TextField(
                        //   controller: emailController,
                        //   decoration: InputDecoration(labelText: 'Email'),
                        // ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                ),
                                onChanged: (value) {
                                  setDialogState(() {}); // refresh UI if needed
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ],
                        ),

                        // Show password validation errors if any
                        if (passwordController.text.isNotEmpty &&
                            !securityApi.validatePassword(
                              passwordController.text,
                              nameController.text,
                              policy,
                            ))
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  securityApi.validationError!
                                      .map(
                                        (err) => Text(
                                          err,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedRole,
                          decoration: InputDecoration(labelText: 'Role'),
                          items: [
                            DropdownMenuItem(
                              value: "viewer",
                              child: Text("Viewer"),
                            ),
                            DropdownMenuItem(
                              value: "admin",
                              child: Text("Admin"),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedRole = newValue!;
                            });
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
                      onPressed: () {
                        if (nameController.text.isNotEmpty) {
                          User user = User.fromJson({
                            'username': nameController.text,
                            //'email': emailController.text,
                            'password': passwordController.text,
                            'role': selectedRole,
                          });
                          userApi.writeUser(user);
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showDeleteUserDialog(User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<UserApi>(
          builder: (context, userApi, _) {
            return AlertDialog(
              title: Text('Delete User'),
              content: Text('Delete ${user.name}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    await userApi.deleteUser(user);
                    Navigator.pop(context);
                  },
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditUserDialog(User user) {
    final nameController = TextEditingController();
    //final emailController = TextEditingController();
    final passwordController = TextEditingController();

    final securityApi = context.read<SecurityApi>();
    SecurityPolicy policy =
        securityApi.securityPolicy!; // Use the getter instead

    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool _obscurePassword = true; // initially obscure

        nameController.text = user.name;
        //emailController.text = user.email;
        passwordController.text = '';
        String selectedRole = user.role;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Consumer<UserApi>(
              builder: (context, userApi, _) {
                return AlertDialog(
                  title: Text('Edit User'),
                  content: SizedBox(
                    width: 400,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(labelText: 'Name'),
                          readOnly: true,
                        ),

                        //TextField(
                        //  controller: emailController,
                        //  decoration: InputDecoration(labelText: 'Email'),
                        //),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password (enter new to change)',
                                ),
                                onChanged: (value) {
                                  setDialogState(() {}); // refresh UI if needed
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ],
                        ),

                        // Show password validation errors if any
                        if (passwordController.text.isNotEmpty &&
                            !securityApi.validatePassword(
                              passwordController.text,
                              nameController.text,
                              policy,
                            ))
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  securityApi.validationError!
                                      .map(
                                        (err) => Text(
                                          err,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedRole,
                          decoration: InputDecoration(labelText: 'Role'),
                          items: [
                            DropdownMenuItem(
                              value: "viewer",
                              child: Text("Viewer"),
                            ),
                            DropdownMenuItem(
                              value: "admin",
                              child: Text("Admin"),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedRole = newValue!;
                            });
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
                      onPressed: () {
                        User user = User.fromJson({
                          'username': nameController.text,
                          // 'email': emailController.text,
                          'password': passwordController.text,
                          'role': selectedRole,
                        });
                        userApi.editUser(user);
                        Navigator.pop(context);
                      },
                      child: Text('Save'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
