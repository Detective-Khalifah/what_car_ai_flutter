import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:what_car_ai_flutter/services/auth_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _autoSaveEnabled = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    // final user = await ref.read(authServiceProvider).getCurrentUser();
    final user = await FirebaseAuth.instance.currentUser;
    setState(() {
      _user = user;
    });
  }

  Future<void> _logOut() async {
    try {
      await ref.read(authServiceProvider).signOut();
      context.go('/');
    } catch (error) {
      print('Logout error: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to log out')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuGroups = [
      {
        'items': [
          {
            'title': 'My Premium Service',
            'subtitle': 'Status: Free',
            'icon': Icons.star,
            'route': '/premium',
            'disabled': true,
          },
        ]
      },
      {
        'items': [
          {
            'title': _user != null ? 'Log Out' : 'Log In / Sign up',
            'icon': _user != null ? Icons.logout : Icons.login,
            'textColor': _user != null ? Colors.red : Colors.grey[900],
            'iconColor': _user != null ? Colors.red : Colors.grey[900],
            'onPress':
                _user != null ? _logOut : () => context.go('/auth/login'),
          },
          {
            'title': 'Drop A Feedback',
            'icon': Icons.favorite,
            'route': '/feedback',
          },
          {
            'title': 'FAQ & Help',
            'icon': Icons.help,
            'route': '/help',
          },
          {
            'title': 'App Info',
            'icon': Icons.info,
            'route': '/about',
          },
          {
            'title': 'Privacy Policy',
            'icon': Icons.privacy_tip,
            'route': '/privacy',
          },
          {
            'title': 'Terms of Use',
            'icon': Icons.description,
            'route': '/terms',
          },
        ]
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ...menuGroups.expand((group) => [
                  ...group['items']!
                      .map((item) => _buildMenuItem(item))
                      .toList(),
                  SizedBox(height: 16),
                ]),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    if (item.containsKey('type') && item['type'] == 'switch') {
      return SwitchListTile(
        title: Text(item['title']),
        value: item['value'],
        onChanged: (value) => item['onValueChange'](value),
        secondary: Icon(item['icon'], color: item['iconColor']),
      );
    }

    return ListTile(
      leading: Icon(item['icon'], color: item['iconColor'] ?? Colors.grey[900]),
      title: Text(item['title'],
          style: TextStyle(color: item['textColor'] ?? Colors.grey[900])),
      subtitle: item.containsKey('subtitle') ? Text(item['subtitle']) : null,
      trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
      onTap: item.containsKey('onPress')
          ? item['onPress']
          : () => context.go(item['route']),
      enabled: item.containsKey('disabled') ? !item['disabled'] : true,
    );
  }
}
