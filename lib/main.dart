import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'api/api_service.dart';
import 'app_data.dart';
import 'screens/home_screen.dart';
import 'screens/post_details_screen.dart';
import 'screens/user_profile_screen.dart';

// --- BINDINGS ---
// InitialBinding to fetch essential data at app start
class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(ApiService());
    Get.put(AppData.instance);
  }
}

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeScreenController>(() => HomeScreenController());
  }
}

class PostDetailsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostDetailsController>(() => PostDetailsController());
  }
}

class UserProfileBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserProfileController>(() => UserProfileController());
  }
}

// --- MAIN APP ---
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Social Media App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      initialBinding: InitialBinding(), // Load initial data
      getPages: [
        GetPage(
          name: '/',
          page: () => const HomeScreen(),
          binding: HomeBinding(),
        ),
        GetPage(
          name: '/post/:postId',
          page: () => const PostDetailsScreen(),
          binding: PostDetailsBinding(),
        ),
        GetPage(
          name: '/user/:userId',
          page: () => const UserProfileScreen(),
          binding: UserProfileBinding(),
        ),
      ],
    );
  }
}
