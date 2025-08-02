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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(16),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'New Post',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Text Area with Avatar
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage(
                      'assets/profile.png',
                    ), // Replace with your asset
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: bodyController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: "What's happening?",
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Title (optional like hashtags or thread title)
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Add a title (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Post Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    if (titleController.text.isNotEmpty ||
                        bodyController.text.isNotEmpty) {
                      _createPost(titleController.text, bodyController.text);
                      Get.back();
                    } else {
                      Get.snackbar('Error', 'Post content cannot be empty.');
                    }
                  },
                  child: const Text('Post'),
                ),
              ),
            ],
          ),
        ),
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
        title: const Text('THREADS'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
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
                  selectionColor: const Color(0xFF2196F3),
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
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        onPressed: () => controller._showCreatePostDialog(context),
        tooltip: 'Create Post',
        child: const Icon(Icons.add),
      ),
    );
  }
}
