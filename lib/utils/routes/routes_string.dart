import 'package:get/get.dart';
import 'package:skill_up/utils/routes/routes.dart';
import 'package:skill_up/view/screens/notificationss/notifications_binding.dart';
import 'package:skill_up/view/screens/notificationss/notifications_view.dart';
import 'package:skill_up/view/screens/profile/profile_binding.dart';
import 'package:skill_up/view/screens/profile/profile_view.dart';

import 'package:skill_up/view/screens/search/search_binding.dart';
import 'package:skill_up/view/screens/search/search_view.dart';

import 'package:skill_up/view/screens/splash/splash_binding.dart';
import 'package:skill_up/view/screens/splash/splash_view.dart';

import 'package:skill_up/view/screens/welcom/welcome_binding.dart';
import 'package:skill_up/view/screens/welcom/welcome_view.dart';

import 'package:skill_up/view/screens/joining/join_binding.dart';
import 'package:skill_up/view/screens/joining/join_view.dart';

import 'package:skill_up/view/screens/signIn/signIn_binding.dart';
import 'package:skill_up/view/screens/signIn/signIn_view.dart';

import 'package:skill_up/view/screens/signUp/signUp_binding.dart';
import 'package:skill_up/view/screens/signUp/signUp_view.dart';

import 'package:skill_up/view/screens/forgetPass/forget_password_binding.dart';
import 'package:skill_up/view/screens/forgetPass/forget_password_view.dart';

import 'package:skill_up/view/screens/home/home_binding.dart';
import 'package:skill_up/view/screens/home/home_view.dart';

final List<GetPage<dynamic>> getPages = [
  GetPage(
    name: RoutesString.splash,
    page: () => const SplashView(),
    binding: SplashBinding(),
  ),
  GetPage(
    name: RoutesString.welcome,
    page: () => const WelcomeView(),
    binding: WelcomeBinding(),
  ),
  GetPage(
    name: RoutesString.join,
    page: () => const JoinView(),
    binding: JoinBinding(),
  ),
  GetPage(
    name: RoutesString.signIn,
    page: () => const SignInView(),
    binding: SignInBinding(),
  ),
  GetPage(
    name: RoutesString.signUp,
    page: () => const SignUpView(),
    binding: SignUpBinding(),
  ),
  GetPage(
    name: RoutesString.forgetPass,
    page: () => const ForgetPasswordView(),
    binding: ForgetPasswordBinding(),
  ),
  GetPage(
    name: RoutesString.home,
    page: () => const HomeView(),
    binding: HomeBinding(),
  ),
  GetPage(
    name: RoutesString.search,
    page: () => const SearchView(),
    binding: SearchBinding(),
  ),
  GetPage(
    name: RoutesString.profile,
    page: () => const ProfileView(),
    binding: ProfileBinding(),
  ),
  GetPage(
    name: RoutesString.notifications,
    page: () => const NotificationsView(),
    binding: NotificationsBinding(),
  ),
];
