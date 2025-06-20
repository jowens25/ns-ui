import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedUsers = await getUsers(); // Your backend call
      setState(() {
        users = fetchedUsers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error - show snackbar or dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load users: $e')));
    }
  }

  // Placeholder for your backend call - replace with your actual implementation
  Future<List<User>> getUsers() async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));

    // Replace this with your actual backend call
    return [
      User(id: '1', name: 'John Doe', email: 'john@example.com'),
      User(id: '2', name: 'Jane Smith', email: 'jane@example.com'),
      User(id: '3', name: 'Bob Johnson', email: 'bob@example.com'),
    ];
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
            // Left Column: Actions
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Actions Header (match height with Users Header)
                    SizedBox(
                      height: 64, // Set a fixed height to match Users header
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Actions',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Actions Card (expand to fill width)
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () => {},
                              child: Text('Security Policy'),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => {},
                              child: Text('LDAP Setup'),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => {},
                              child: Text('RADIUS Setup'),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => {},
                              child: Text('TACACS+ Setup'),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => {},
                              child: Text('Change My Password'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Right Column: Users
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 16, right: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Users Header (same fixed height)
                    SizedBox(
                      height: 64, // Match height with Actions header
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Users',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),

                              IconButton(
                                onPressed: _loadUsers,
                                icon: const Icon(Icons.refresh, size: 20),
                                tooltip: 'Refresh Users',
                              ),
                              IconButton(
                                onPressed: _showAddUserDialog,
                                icon: const Icon(Icons.add, size: 20),
                                tooltip: 'Add User',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Users List Card
                    Card(
                      child: Container(
                        height: 400,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: _buildUsersList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUsersList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (users.isEmpty) {
      return Center(
        child: Text(
          'No users found',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return _buildUser(users[index]);
      },
    );
  }

  Widget _buildUser(User user) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              child: Text(user.name.substring(0, 1)),
              backgroundColor: Colors.blue[100],
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            Text(
              'ID: ${user.id}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    // Handle edit user
                    break;
                  case 'delete':
                    // Handle delete user
                    _showDeleteConfirmation(user);
                    break;
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
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(User user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete User'),
            content: Text('Are you sure you want to delete ${user.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteUser(user);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _deleteUser(User user) async {
    try {
      // Call your backend to delete the user
      // await deleteUser(user.id);

      setState(() {
        users.removeWhere((u) => u.id == user.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ${user.name} deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete user: $e')));
    }
  }

  void _showAddUserDialog() {
    final _formKey = GlobalKey<FormState>();
    String name = '';
    String email = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add User'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Enter a name'
                              : null,
                  onSaved: (value) => name = value ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Enter an email'
                              : null,
                  onSaved: (value) => email = value ?? '',
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
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  setState(() {
                    users.add(
                      User(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        email: email,
                      ),
                    );
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('User $name added')));
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  // Add factory constructor for JSON parsing if needed
  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], name: json['name'], email: json['email']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}
