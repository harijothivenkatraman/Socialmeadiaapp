import 'models/comment_model.dart';
import 'models/post_model.dart';
import 'models/user_model.dart';

class AppData {
  // Singleton setup
  AppData._privateConstructor();
  static final AppData _instance = AppData._privateConstructor();
  static AppData get instance => _instance;

  // Data storage
  List<PostModel> posts = [];
  List<UserModel> users = [];
  Map<int, List<CommentModel>> commentsByPostId = {};

  // Methods to manage data
  void setPosts(List<PostModel> newPosts) {
    posts = newPosts;
  }

  void addPost(PostModel newPost) {
    // Add new post to the beginning of the list
    posts.insert(0, newPost);
  }

  void setUsers(List<UserModel> newUsers) {
    users = newUsers;
  }

  void setCommentsForPost(int postId, List<CommentModel> postComments) {
    commentsByPostId[postId] = postComments;
  }

  // Methods to retrieve data
  PostModel? getPostById(int postId) {
    try {
      return posts.firstWhere((post) => post.id == postId);
    } catch (_) {
      return null;
    }
  }

  UserModel? getUserById(int userId) {
    try {
      return users.firstWhere((user) => user.id == userId);
    } catch (_) {
      return null;
    }
  }

  List<CommentModel> getCommentsForPost(int postId) {
    return commentsByPostId[postId] ?? [];
  }
}
