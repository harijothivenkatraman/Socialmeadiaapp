import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app_data.dart';
import '../api/api_service.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

// Controller
class PostDetailsController extends GetxController {
  final ApiService _apiService = ApiService();
  final AppData _appData = AppData.instance;

  final int postId = int.parse(Get.parameters['postId']!);

  var isLoading = true.obs;
  PostModel? post;
  UserModel? user;
  var comments = <CommentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    isLoading.value = true;
    try {
      // Get post and user from singleton
      post = _appData.getPostById(postId);
      if (post != null) {
        user = _appData.getUserById(post!.userId);
      }

      // Fetch comments if not already cached
      if (_appData.getCommentsForPost(postId).isEmpty) {
        final fetchedComments = await _apiService.getComments(postId);
        _appData.setCommentsForPost(postId, fetchedComments);
      }
      comments.assignAll(_appData.getCommentsForPost(postId));
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

// UI
class PostDetailsScreen extends GetView<PostDetailsController> {
  const PostDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.post == null) {
          return const Center(child: Text('Post not found.'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.post!.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Get.toNamed('/user/${controller.post!.userId}'),
                child: Text(
                  'by ${controller.user?.name ?? 'Unknown User'}',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF2196F3),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                controller.post!.body,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Divider(height: 40),
              Text('Comments', style: Theme.of(context).textTheme.titleLarge),
              _buildCommentsSection(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCommentsSection() {
    return Obx(() {
      if (controller.comments.isEmpty) {
        return const Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Center(child: Text('No comments yet.')),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.comments.length,
        itemBuilder: (context, index) {
          final comment = controller.comments[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                comment.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(comment.body),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                child: Text(comment.email[0].toUpperCase()),
              ),
            ),
          );
        },
      );
    });
  }
}
