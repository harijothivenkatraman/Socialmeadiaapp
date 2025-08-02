// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app_data.dart';
import '../api/api_service.dart';
import '../models/post_model.dart';

// Controller
class HomeScreenController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AppData _appData = Get.find<AppData>();

  var isLoading = true.obs;
  var posts = <PostModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // The controller is now responsible for fetching its own data.
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    try {
      isLoading.value = true;
      // Fetch both posts and users and wait for them to complete.
      final fetchedPosts = await _apiService.getPosts();
      final fetchedUsers = await _apiService.getUsers();

      // Store data in the singleton for other screens to use.
      _appData.setPosts(fetchedPosts);
      _appData.setUsers(fetchedUsers);

      // Update the local observable list for the UI.
      posts.assignAll(fetchedPosts);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showCreatePostDialog(BuildContext context) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(labelText: 'Body'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  bodyController.text.isNotEmpty) {
                _createPost(titleController.text, bodyController.text);
                Get.back();
              } else {
                Get.snackbar('Error', 'Title and body cannot be empty.');
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _createPost(String title, String body) async {
    // For creating a post, we don't need to set the global loading state
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      final newPostData = PostModel(
        userId: 1,
        id: 0,
        title: title,
        body: body,
      ); // API assigns ID
      final createdPost = await _apiService.createPost(newPostData);
      _appData.addPost(createdPost);
      posts.insert(0, createdPost); // Update UI

      Get.back(); // Dismiss the loading indicator dialog
      Get.snackbar(
        'Success',
        'Post created successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.back(); // Dismiss the loading indicator dialog
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }
}

// UI
class HomeScreen extends GetView<HomeScreenController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchInitialData(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.posts.isEmpty) {
          return const Center(child: Text("No posts found. Try refreshing."));
        }
        return ListView.builder(
          itemCount: controller.posts.length,
          itemBuilder: (context, index) {
            final post = controller.posts[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  post.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  post.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => Get.toNamed('/post/${post.id}'),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller._showCreatePostDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
