// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:jop_finder_app/core/constants/app_colors.dart';
import 'package:jop_finder_app/core/utils/app_router.dart';
import 'package:jop_finder_app/features/auth/data/model/UserProfile_model.dart';
import 'package:jop_finder_app/features/auth/data/model/user_model.dart';
import 'package:jop_finder_app/features/profile/view/widgets/edit_info_bottom_sheet.dart';
import 'package:jop_finder_app/features/profile/view/widgets/edit_bio_bottomsheet.dart';
import 'package:jop_finder_app/features/profile/view/widgets/education_add_bottomsheet.dart';
import 'package:jop_finder_app/features/profile/view/widgets/info_display.dart';
import 'package:jop_finder_app/features/profile/viewmodel/profile_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  
  UserModel? user;
  ProfileCubit? profileCubit;

  @override
  void initState() {
    super.initState();
    profileCubit = BlocProvider.of<ProfileCubit>(context);
    // Schedule the asynchronous operation to fetch user information
    WidgetsBinding.instance.addPostFrameCallback((context) {
      _fetchUserInfo();
    });
  }

  Future<void> _fetchUserInfo() async {
    // Fetch user information from Firestore using the cubit method
    var fetchedUser =
        await BlocProvider.of<ProfileCubit>(context).getUserInfo();
    if (fetchedUser.profile == null) {
      UserProfile userProfile = UserProfile(
        bio: 'No bio added',
        education: [],
        jobTitle: 'No job title',
        status: 'No status',
      );
      BlocProvider.of<ProfileCubit>(context).updateUserProfile(userProfile);
    }

    // Update the Firestore with the default profile
    if (mounted) {
      setState(() {
        user = fetchedUser;
      });
    }
  }

  Widget buildBlock() {
    if (profileCubit == null) {
      return Center(child: Text('ProfileCubit is null'));
    }
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is UserLoaded) {
          user = state.user;
          return buildProfileScreen();
        } else if (state is UserUpdated) {
          user = state.user;
          return buildProfileScreen();
        } else if (state is ProfileError) {
          return Center(child: Text(state.errorMessage));
        } else {
          return Center(child: Text('Error occurred'));
        }
      },
    );
  }

  Widget logOutLis() {
    if (profileCubit == null) {
      return Center(child: Text('ProfileCubit is null'));
    }
    return BlocListener<ProfileCubit, ProfileState>(listener: (context, state) {
      if (state is SignedOut) {
        GoRouter.of(context).pushReplacementNamed(AppRouter.login);
      }
    });
  }

  Widget buildProfileScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView(
        children: [
          SizedBox(height: 16),
          Center(
              child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60.sp,
                backgroundImage: NetworkImage(
                    user!.profileImageUrl ??
                        'https://pinnaclera.com/wp-content/uploads/2023/02/default_profile_image.png',
                    scale: 1.0),
                // Replace with actual image URL
              ),
              Positioned(
                // Adjust this value to position the icon on the frame
                right:
                    7.sp, // Adjust this value to position the icon on the frame
                child: Container(
                  padding: EdgeInsets.all(5), // Adjust padding if necessary
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      profileCubit!.pickImageAndUpdateUser();
                    },
                    icon: Icon(Icons.edit, color: Colors.white),
                    iconSize: 15.sp, // Adjust icon size if necessary
                    padding: EdgeInsets
                        .zero, // Reduce padding inside IconButton to minimize size
                    constraints:
                        BoxConstraints(), // Remove minimum size constraints
                  ),
                ),
              ),
            ],
          )),
          SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                Text(
                  user!.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user!.profile!.jobTitle ?? 'No job title',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    Icon(
                      Icons.verified,
                      color: AppColors.primaryBlue,
                      size: 16,
                    )
                  ],
                )
              ],
            ),
          ),
          SizedBox(height: 40),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      user!.appliedJobs!.length.toString(),
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    Text(
                      'Applied',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      user!.profile!.status ?? 'No status',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    Text(
                      'Status',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 44),
          Row(
            children: [
              Expanded(
                child: CustomInfoDisplay(text: user!.email, icon: Icons.email),
              ),
              SizedBox(width: 10.w), // Adjust spacing based on your layout
              Expanded(
                child: CustomInfoDisplay(
                    text: user!.phoneNumber ?? 'No phone number',
                    icon: Icons.phone_android_outlined),
              ),
            ],
          ),
          SizedBox(height: 24),
          buildBioHeader('Bio', onPressed: () {
            showDialog(
              context: context,
              builder: (context) => EditBioDialog(profileCubit!),
            );
          }),
          SizedBox(height: 10),
          CustomBioDisplay(text: user!.profile!.bio ?? 'No bio added'),
          SizedBox(height: 28),
          buildSectionHeader('Education', onPressed: () {
            showDialog(
              context: context,
              builder: (context) => EducationAddDialog(profileCubit!),
            );
          }),
          SizedBox(height: 10),
          buildEducationSection(),
          SizedBox(height: 26),
          buildSectionHeader('Resume', onPressed: () {
            GoRouter.of(context).pushNamed('/resumeUploadScreen');
          }),
          resumeDisplay(),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      EditInfoDialog(profileCubit!, user!),
                );
              },
              icon: Icon(
                Icons.edit,
              ),
            ),
            IconButton(
              onPressed: () {
                GoRouter.of(context).pushNamed('/settingsScreen');
              },
              icon: Icon(
                Icons.settings,
              ),
            )
          ],
        ),
        body: BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is SignedOut || state is AccountDeleted) {
              GoRouter.of(context).pushReplacementNamed(AppRouter.login);
            }
          },
          child: buildBlock(),
        ),
      ),
    );
  }

  Widget buildSectionHeader(String title, {required VoidCallback onPressed}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            'Add',
            style: TextStyle(color: AppColors.primaryBlue),
          ),
        )
      ],
    );
  }

  Widget buildBioHeader(String title, {required VoidCallback onPressed}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            'Edit',
            style: TextStyle(color: AppColors.primaryBlue),
          ),
        )
      ],
    );
  }

  Widget buildEducationItem({
    required Education? education,
  }) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.school, size: 40, color: AppColors.primaryBlue),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    education!.fieldOfStudy ?? 'No Field',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    education.degree ?? 'No Degree',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    '${education.institution ?? 'no institution'}  • ${education.startDate!.year} - ${education.endDate!.year}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              )
            ],
          ),
          IconButton(
            onPressed: () {
              profileCubit!.removeEducation(education);
            },
            icon: Icon(Icons.delete, color: AppColors.primaryBlue),
          )
        ],
      ),
    );
  }

  Widget resumeDisplay() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      child: (user?.cvUrl == null || user!.cvUrl!.isEmpty)
          ? Center(
              child: Text('No CV. Add one.'.toUpperCase(),
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(width: 4), // Spacing between icon and text
                    Icon(
                      Icons.file_present,
                      size: 30,
                      color: AppColors.primaryBlue,
                    ), // File icon
                    SizedBox(width: 12), // Spacing between icon and text
                    InkWell(
                      onTap: () {
                        profileCubit!.openPdf(user!.cvUrl!);
                      },
                      child: Text('${user!.name}_CV.pdf',
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ), // Displaying the file name extracted from the URL
                  ],
                ),
                IconButton(
                  onPressed: () {
                    profileCubit!.customUpdateToFirebase("cvUrl", "");
                  },
                  icon: Icon(Icons.delete, color: AppColors.primaryBlue),
                )
              ],
            ),
    );
  }

  Widget buildEducationSection() {
    if (user?.profile?.education == null || user!.profile!.education!.isEmpty) {
      return Center(
        child: Text('No education added'.toUpperCase(),
            style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    } else {
      return ListView.builder(
        shrinkWrap:
            true, // This ensures the ListView takes only the necessary height
        physics: NeverScrollableScrollPhysics(),
        itemCount: user!.profile!.education!.length,
        itemBuilder: (context, index) {
          return buildEducationItem(
              education: user!.profile!.education![index]);
        },
      );
    }
  }
}
