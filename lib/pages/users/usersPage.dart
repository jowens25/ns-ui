import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';
import 'package:ntsc_ui/api/LoginApi.dart';
import 'package:provider/provider.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
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
    return BasePage(
      title: 'User Management',
      description: 'Manage users and their permissions.',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Actions Column
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Card(
                  child: Container(
                    height: 400,
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Actions',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        SizedBox(height: 8),
                        SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _showNotImplemented(),
                            child: Text('LDAP Setup'),
                          ),
                        ),
                        SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _showNotImplemented(),
                            child: Text('RADIUS Setup'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Users Column
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 16, right: 16, bottom: 16),
                child: Card(
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Users',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
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
                            ),
                          ],
                        ),
                      ),
                      // Users List
                      Container(
                        height: 400,
                        padding: EdgeInsets.all(16),
                        child: _buildUsersList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUsersList() {
    return Consumer<LoginApi>(
      builder: (context, loginApi, _) {
        if (loginApi.filteredUsers.isEmpty) {
          return Center(
            child: Text(
              'No users found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          );
        }

        return ListView.builder(
          itemCount: loginApi.filteredUsers.length,
          itemBuilder: (context, index) {
            final user = loginApi.filteredUsers[index];
            return Card(
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
                      _showDeleteDialog(user, loginApi);
                    }
                  },
                  itemBuilder:
                      (context) => [
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
            );
          },
        );
      },
    );
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<LoginApi>(
          builder: (context, loginApi, _) {
            String selectedRole =
                "viewer"; // Add this as a variable in your widget state

            return AlertDialog(
              title: Text('Add User'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(labelText: 'Role'),
                    items: [
                      DropdownMenuItem(value: "viewer", child: Text("Viewer")),
                      DropdownMenuItem(value: "admin", child: Text("Admin")),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRole = newValue!;
                      });
                    },
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
                    if (nameController.text.isNotEmpty &&
                        emailController.text.isNotEmpty) {
                      await loginApi.addUser(
                        selectedRole,
                        nameController.text,
                        emailController.text,
                        passwordController.text,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('User added')));
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
  }

  void _showDeleteDialog(User user, LoginApi loginApi) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete User'),
            content: Text('Delete ${user.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await loginApi.deleteUser(user);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('User deleted')));
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showNotImplemented() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Not implemented yet')));
  }
}
