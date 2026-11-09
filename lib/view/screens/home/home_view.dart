import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:skill_up/view/screens/MyCourses/MyCourses_view.dart';
import 'package:skill_up/view/screens/create_video/create_video_view.dart';
import 'package:skill_up/view/screens/home/course_card.dart';
import 'package:skill_up/view/screens/notificationss/notifications_view.dart';
import 'package:skill_up/view/screens/profile/profile_view.dart';
import 'package:skill_up/view/screens/MyCourses/course_details_view.dart';
import 'package:skill_up/view/screens/all_courses/see_all_view.dart';

import 'package:skill_up/controllers/user_controller.dart';
import 'package:skill_up/data/models/course_model.dart';
import 'package:skill_up/data/models/user_model.dart';
import 'package:skill_up/view/screens/saved/saved_controller.dart';
import 'package:skill_up/view/screens/saved/saved_view.dart';
import 'package:skill_up/utils/image_helper.dart';
import 'package:skill_up/data/themes/image_string.dart';
import 'package:skill_up/utils/routes/routes.dart';
import 'home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController ctrl = Get.put(HomeController());

    Get.put(SavedController());

    final UserController userCtrl = Get.find<UserController>();

    final List<Widget> pages = [
      const _HomeContent(),
      const MyCoursesView(),
      const SavedView(),
      const ProfileView(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () => IndexedStack(index: ctrl.currentIndex.value, children: pages),
      ),

      floatingActionButton: Obx(() {
        if (userCtrl.role.value == UserRole.teacher) {
          return FloatingActionButton(
            onPressed: () => Get.to(() => const CreateVideoView()),
            child: const Icon(Icons.video_call),
          );
        }
        return const SizedBox.shrink();
      }),

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 2, thickness: 2, color: Colors.grey),
          Obx(
            () => BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: ctrl.currentIndex.value,
              onTap: ctrl.changeTab,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_filled),
                  label: 'home'.tr,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: 'courses'.tr,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.bookmark_border),
                  label: 'saved'.tr,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline),
                  label: 'profile'.tr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  late final HomeController ctrl;
  late final UserController userCtrl;
  Worker? _readyWorker;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<HomeController>();
    userCtrl = Get.find<UserController>();

    if (userCtrl.isReady.value && userCtrl.uid.value.isNotEmpty) {
      if (userCtrl.role.value == UserRole.student) {
        ctrl.loadContinueWatching(userCtrl.uid.value);
      }
    } else {
      _readyWorker = ever(userCtrl.isReady, (ready) {
        if (ready == true && userCtrl.uid.value.isNotEmpty) {
          if (userCtrl.role.value == UserRole.student) {
            ctrl.loadContinueWatching(userCtrl.uid.value);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _readyWorker?.dispose();
    super.dispose();
  }

  void _openCourseDetails(Map<String, dynamic> map) {
    Get.to(() => CourseDetailsView(course: map));
  }

  void _openSeeAll(
    String title,
    List<Map<String, dynamic>> raw,
    List<CourseModel> models,
  ) {
    Get.to(() => SeeAllCoursesView(
          title: title,
          rawCourses: raw,
          modelCourses: models,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        if (!userCtrl.isReady.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (userCtrl.uid.value.isNotEmpty) {
              await ctrl.refreshHome(uid: userCtrl.uid.value);
            } else {
              await ctrl.loadTrending();
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => ctrl.changeTab(3),
                        child: Obx(() {
                          return CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: resolveImage(
                              userCtrl.photoUrl.value,
                              fallbackAsset: ImageStringProfile.userProfile,
                            ),
                          );
                        }),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: GestureDetector(
                        onTap: () => ctrl.changeTab(3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                              () => Text(
                                userCtrl.fullName.value.isNotEmpty
                                    ? userCtrl.fullName.value
                                    : '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (userCtrl.role.value == UserRole.teacher)
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Verified Teacher',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () => Get.to(() => const NotificationsView()),
                      child: Stack(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            child: const Icon(Icons.notifications_none),
                          ),
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Get.toNamed(RoutesString.search),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: ctrl.searchController,
                      onChanged: ctrl.onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'searchAnyCourse'.tr,
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: Obx(
                          () => ctrl.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    ctrl.searchController.clear();
                                    ctrl.onSearchChanged('');
                                  },
                                )
                              : const SizedBox.shrink(),
                        ),
                        filled: true,
                        fillColor: const Color(0xfff5f6fb),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Obx(() {
                  if (ctrl.skills.isEmpty) return const SizedBox.shrink();
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ctrl.skills
                          .map((skill) => _chip(skill))
                          .toList(),
                    ),
                  );
                }),
                const SizedBox(height: 24),

                if (userCtrl.role.value == UserRole.teacher) ...[
                  Text(
                    'teacherDashboard'.tr,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'teacherDesc'.tr,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 24),

                  _sectionHeader(
                    'trendingNow'.tr,
                    onSeeAll: () => _openSeeAll(
                      'trendingNow'.tr,
                      ctrl.trendingRaw.toList(),
                      ctrl.trendingCourses.toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _TrendingList(onOpen: _openCourseDetails),
                ] else ...[
                  Obx(() {
                    if (ctrl.isLoadingContinue.value) {
                      return const SizedBox(
                        height: 230,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (ctrl.filteredContinue.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader(
                          'continueWatching'.tr,
                          onSeeAll: () => _openSeeAll(
                            'continueWatching'.tr,
                            ctrl.continueRaw.toList(),
                            ctrl.continueWatchingCourses.toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 230,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: ctrl.filteredContinue.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final course = ctrl.filteredContinue[index];

                              final rawIndex = ctrl.continueWatchingCourses
                                  .indexOf(course);
                              final map = ctrl.continueMapAt(rawIndex);

                              return GestureDetector(
                                onTap: () => _openCourseDetails(map),
                                child: CourseCard(course: course),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  }),

                  _sectionHeader(
                    'trendingNow'.tr,
                    onSeeAll: () => _openSeeAll(
                      'trendingNow'.tr,
                      ctrl.trendingRaw.toList(),
                      ctrl.trendingCourses.toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _TrendingList(onOpen: _openCourseDetails),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _TrendingList extends StatelessWidget {
  final void Function(Map<String, dynamic>) onOpen;
  const _TrendingList({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final HomeController ctrl = Get.find<HomeController>();

    return Obx(() {
      if (ctrl.isLoadingTrending.value) {
        return const SizedBox(
          height: 230,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (ctrl.filteredTrending.isEmpty) {
        return SizedBox(
          height: 120,
          child: Center(
            child: Text(
              'noTrendingCourses'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      return SizedBox(
        height: 230,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: ctrl.filteredTrending.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final course = ctrl.filteredTrending[index];
            final rawIndex = ctrl.trendingCourses.indexOf(course);
            final map = ctrl.trendingMapAt(rawIndex);

            return GestureDetector(
              onTap: () => onOpen(map),
              child: CourseCard(course: course),
            );
          },
        ),
      );
    });
  }
}

Widget _chip(String text) {
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xfff3e9ff),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

Widget _sectionHeader(String title, {VoidCallback? onSeeAll}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      if (onSeeAll != null)
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            'seeAll'.tr,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
    ],
  );
}
