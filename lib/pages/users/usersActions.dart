import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';
import 'package:ntsc_ui/api/LoginApi.dart';
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
      final loginApi = context.read<LoginApi>();
      loginApi.getAllUsers();
      _searchController.addListener(() {
        loginApi.searchUsers(_searchController.text);
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
                onPressed: () => _showNotImplemented(),
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
  //    return Consumer<LoginApi>(
  //      builder: (context, loginApi, _) {
  //        if (loginApi.filteredUsers.isEmpty) {
  //          return Center(
  //            child: Text(
  //              'No users found',
  //              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
  //            ),
  //          );
  //        }
  //
  //        return ListView.builder(
  //          itemCount: loginApi.filteredUsers.length,
  //          itemBuilder: (context, index) {
  //            final user = loginApi.filteredUsers[index];
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
  //        return Consumer<LoginApi>(
  //          builder: (context, loginApi, _) {
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
  //                      await loginApi.addUser(
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
  //        return Consumer<LoginApi>(
  //          builder: (context, loginApi, _) {
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
  //                    await loginApi.deleteUser(user);
  //                    Navigator.pop(context);
  //                    ScaffoldMessenger.of(context).showSnackBar(
  //                      SnackBar(content: Text(loginApi.messageError)),
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
  //        return Consumer<LoginApi>(
  //          builder: (context, loginApi, _) {
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
  //                      await loginApi.updateUser(user);
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
}
