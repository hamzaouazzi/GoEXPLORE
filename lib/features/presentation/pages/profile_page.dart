import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../injection_container.dart';
import '../../../src/widgets/custom_app_bar_action.dart';
import '../../data/models/user_model.dart';


class ProfilePage extends StatefulWidget {
  static const String routeName = '/profile';
  final String userId;

  const ProfilePage({this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel user;

  // @override
  // void didChangeDependencies() {
  //   user = UserModel.fromJson(
  //     json.decode(
  //       serviceLocator<SharedPreferences>().getString('user'),
  //     ),
  //   );
  //   super.didChangeDependencies();
  // }

  Stream _getUserDataStream() {
    UserModel user;
    if (widget.userId == null) {
      user = _getCurrentUserData();
      return Stream.value(user);
    } else {
      return serviceLocator<Firestore>()
          .collection('users')
          .document(widget.userId)
          .snapshots();
    }
  }

  UserModel _getCurrentUserData() {
    final userJsonString =
        serviceLocator<SharedPreferences>().getString('user');
    UserModel user;
    if (userJsonString != null)
      user = UserModel.fromJson(
        json.decode(userJsonString),
      );
    return user;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: StreamBuilder(
          stream: _getUserDataStream(),
          builder: (_, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data is UserModel) {
              user = snapshot.data;
            } else if (snapshot.data is DocumentSnapshot) {
              user = UserModel.fromJson(snapshot.data.data);
            }
            return Stack(
              children: [
                Container(
                  color: Theme.of(context).primaryColor,
                  height: screenSize.height,
                  width: screenSize.width,
                ),
                Positioned(
                  top: 30.0,
                  child: CustomAppBarAction(
                    height: 45.0,
                    icon: Icons.arrow_back_ios,
                    onActionPressed: _goBack,
                  ),
                ),
                Positioned(
                  top: 30.0,
                  right: 0.0,
                  child: CustomAppBarAction(
                    height: 45.0,
                    icon: widget.userId == null ||
                            widget.userId == _getCurrentUserData().id
                        ? Icons.edit
                        : Icons.delete_sweep, onActionPressed: () {  },
                  ),
                ),
                Positioned(
                  top: screenSize.height * 0.25,
                  child: Container(
                    width: screenSize.width,
                    height: screenSize.height * 0.75,
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35.0),
                        topRight: Radius.circular(35.0),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: screenSize.height * 0.15,
                        left: 15.0,
                        right: 15.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            user.displayName,
                            style: Theme.of(context)
                                .textTheme
                                .title
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            user.email,
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          user.phoneNumber != null
                              ? Text(user.phoneNumber)
                              : Container(),
                          _buildProfileInfoTabBar(),
                          _buildProfileInfoTabBarView(),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildUserImageAvatar(screenSize),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileInfoTabBar() {
    return TabBar(
      labelColor: Theme.of(context).primaryColor,
      unselectedLabelColor: Colors.black,
      indicatorColor: Theme.of(context).accentColor,
      tabs: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: FittedBox(
            child: Text(
              'Friend Requests',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'Add Friends',
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfoTabBarView() {
    return Expanded(
      child: TabBarView(
        children: [
           Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.do_not_disturb_alt,
                        size: 40,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'You can not see this content because it is private content.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
          
        ],
      ),
    );
  }

  Widget _buildUserImageAvatar(screenSize) {
    return Positioned(
      top: screenSize.height * 0.12,
      left: screenSize.width * 0.3,
      child: Hero(
        tag: 'user-avatar',
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: user.photoUrl != null && user.photoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      width: 160,
                      height: MediaQuery.of(context).size.width * 0.4,
                      imageUrl: user.photoUrl,
                      fit: BoxFit.cover,
                    )
                  : CircleAvatar(
                      radius: 80.0,
                      backgroundColor: Colors.transparent,
                      backgroundImage: AssetImage(
                        'assets/images/icon_user.png',
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }



  void _goBack() {
    Navigator.of(context).pop();
  }
}
