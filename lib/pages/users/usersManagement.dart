import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';
import 'package:ntsc_ui/api/UserApi.dart';
import 'package:provider/provider.dart';

class UsersManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'User Management',
      description: 'Management:',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [UsersManagementCard()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

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
    return Card(
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Users', style: TextStyle(fontWeight: FontWeight.bold)),
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
          ),
          // Users List
          Container(
            height: 400,
            padding: EdgeInsets.all(16),
            child: _buildUsersList(),
          ),
        ],
      ),
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
        return Consumer<UserApi>(
          builder: (context, userApi, _) {
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
                    obscureText: true,
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
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        emailController.text.isNotEmpty) {
                      User user = User.fromJson({
                        'username': nameController.text,
                        'email': emailController.text,
                        'password': passwordController.text,
                        'role': selectedRole,
                      });
                      userApi.writeUser(user);
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
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("User Deleted??")));
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
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<UserApi>(
          builder: (context, userApi, _) {
            //
            nameController.text = user.name;
            emailController.text = user.email;
            passwordController.text = 'userpassword';
            String selectedRole = user.role;
            //String selectedRole = "viewer";

            return AlertDialog(
              title: Text('Edit User'),
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
                    obscureText: true,
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
                      user.name = nameController.text;
                      user.email = emailController.text;
                      user.password = passwordController.text;
                      user.role = selectedRole;
                      await userApi.editUser(user);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('User updated')));
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
