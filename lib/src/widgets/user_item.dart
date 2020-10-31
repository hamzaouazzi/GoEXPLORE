import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../pages/chat_page.dart';
import 'custom_action_button.dart';

class UserItem extends StatefulWidget {
  final DocumentSnapshot userDocument;
  

  const UserItem({
    @required this.userDocument,
  
  });

  @override
  _UserItemState createState() => _UserItemState();
}

class _UserItemState extends State<UserItem> {
 
  @override
  Widget build(BuildContext context) {
    return Card(
      // color: Colors.grey[100],
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 5.0,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
           
            splashColor: Theme.of(context).splashColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: widget.userDocument.data['photoUrl'] == null ||
                            widget.userDocument.data['photoUrl'].isEmpty
                        ? Image.asset('assets/images/icon_user.png')
                        : CachedNetworkImage(
                            imageUrl: widget.userDocument.data['photoUrl'],
                            height: 50.0,
                            width: 50.0,
                            fit: BoxFit.fill,
                          ),
                  ),
                  title: Text(
                    widget.userDocument.data['displayName'],
                    style: Theme.of(context).textTheme.title.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                  ),
                  subtitle: Text(
                    widget.userDocument.data['email'],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openChatPage() {
    Routes.sailor.navigate(ChatPage.routeName, params: {
      'peerId': widget.userDocument.data['id'],
      'peerName': widget.userDocument.data['displayName'],
      'peerImageUrl': widget.userDocument.data['photoUrl'],
    });
  }
}
