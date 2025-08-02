import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app_data.dart';
import '../models/user_model.dart';

// Controller
class UserProfileController extends GetxController {
  final AppData _appData = AppData.instance;
  final int userId = int.parse(Get.parameters['userId']!);

  UserModel? user;

  @override
  void onInit() {
    super.onInit();
    // User data is fetched on app start, so we just get it from the singleton
    user = _appData.getUserById(userId);
  }
}

// UI
class UserProfileScreen extends GetView<UserProfileController> {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = controller.user;
    return Scaffold(
      appBar: AppBar(
        title: Text(user?.name ?? 'User Profile'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: user == null
          ? const Center(child: Text('User not found.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildProfileCard(user, context),
                  const SizedBox(height: 20),
                  _buildContactCard(user),
                ],
              ),
            ),
    );
  }

  Card _buildProfileCard(UserModel user, BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              radius: 50,
              child: Text(user.name[0], style: const TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 16),
            Text(user.name, style: Theme.of(context).textTheme.headlineMedium),
            Text(
              '@${user.username}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Card _buildContactCard(UserModel user) {
    return Card(
      elevation: 4,
      child: ListTileTheme(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 4.0,
        ),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.email),
              iconColor: const Color(0xFF2196F3),
              title: const Text('Email'),
              subtitle: Text(user.email),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              iconColor: const Color(0xFF2196F3),
              title: const Text('Phone'),
              subtitle: Text(user.phone),
            ),
            ListTile(
              leading: const Icon(Icons.web),
              iconColor: const Color(0xFF2196F3),
              title: const Text('Website'),
              subtitle: Text(user.website),
            ),
            ListTile(
              leading: const Icon(Icons.location_city),
              iconColor: const Color(0xFF2196F3),
              title: const Text('Address'),
              subtitle: Text(
                '${user.address.street}, ${user.address.suite}, ${user.address.city}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
