import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Helpers/AppColors.dart';
import '../Helpers/ConstData.dart';
import '../models/message_model.dart';
import '../models/room_model.dart';
import '../models/user_model.dart';
import '../push_notifications.dart';
import '../widgets/chat_item.dart';

class ChattingScreen extends StatefulWidget {
  RoomModel roomModel;
  UserModel userModel;
  final dynamic displayName;

  ChattingScreen({Key key, this.roomModel, this.userModel, this.displayName})
      : super(key: key);

  @override
  _ChattingScreenState createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  CollectionReference chatsCollectionReferance;
  final TextEditingController _controller = TextEditingController();
  bool emojiShowing = false;
  double height;
  double width;

  bool show = false;
  FocusNode focusNode = FocusNode();

  final ScrollController _scrollController = ScrollController();
  DocumentSnapshot _userDetails;

  @override
  void initState() {
    super.initState();
    chatsCollectionReferance = FirebaseFirestore.instance
        .collection("chats")
        .doc(widget.roomModel.roomId)
        .collection("messages");

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          show = false;
        });
      }
    });
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((userDocument) => _userDetails = userDocument);
  }

  maxScroll() async {}

  _onEmojiSelected(Emoji emoji) {
    _controller
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
  }

  _onBackspacePressed() {
    _controller
      ..text = _controller.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
  }

  scrollToBottom() async {
    _scrollController.jumpTo(
      _scrollController.position.maxScrollExtent,
      // duration: const Duration(milliseconds: 500),
      // curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Image.asset(
          "assets/chat_bg.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: AppBar(
                  backgroundColor: AppColors.primary,
                  titleSpacing: 0.0,
                  leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      size: 24,
                    ),
                  ),
                  title: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(widget.userModel.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundImage: snapshot.data["profileImage"] ==
                                      null
                                  ? NetworkImage(
                                      ConstData.profilelogo,
                                    )
                                  : NetworkImage(snapshot.data["profileImage"]),
                              backgroundColor: Colors.blueGrey,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Container(
                              margin: const EdgeInsets.all(6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.displayName == ""
                                        ? snapshot.data["name"]
                                        : widget.displayName,
                                    style: const TextStyle(
                                      fontSize: 18.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    snapshot.data["status"],
                                    style: const TextStyle(
                                      fontSize: 13,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      return Container(
                        color: Colors.white,
                      );
                    },
                  ))),
          body: SizedBox(
              height: show
                  ? height - 416
                  : height - MediaQuery.of(context).viewInsets.bottom - 116,
              //keyboardHeight + int.parse(show ? "356" : "56"),
              width: width,
              child: WillPopScope(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    // height: MediaQuery.of(context).size.height -
                    //     keyboardHeight -
                    //     int.parse("${show == true ? 300 + 150 : 150}"),
                    child: StreamBuilder<QuerySnapshot>(
                        stream: chatsCollectionReferance
                            .orderBy("timeStamp")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          } else {
                            if (snapshot.data.docs.isEmpty) {
                              return const Center(
                                  child: Text("No chats Found"));
                            } else {
                              Timer(const Duration(milliseconds: 10),
                                  () => scrollToBottom());
                              updateReadStatus(snapshot);
                              return ListView.builder(
                                  controller: _scrollController,
                                  itemCount: snapshot.data.docs.length,
                                  itemBuilder: (ctx, index) {
                                    MessageModel messageModel =
                                        MessageModel.fromMap(
                                            snapshot.data.docs[index].data());
                                    return ChatItem(messageModel);
                                  });
                            }
                          }
                        })),
                onWillPop: () {
                  if (show) {
                    setState(() {
                      show = false;
                    });
                  } else {
                    Navigator.pop(context);
                  }
                  return Future.value(false);
                },
              )),
          bottomNavigationBar: bottomNavigationBar(),
        )
      ],
    );
  }

  bool isUpdateReadStatus = false;

  updateReadStatus(snapshot) {
    isUpdateReadStatus = true;
    for (int i = 0; i < snapshot.data.docs.length; i++) {
      DocumentSnapshot result = snapshot.data.docs[i];
      Map<String, dynamic> dt = result.data();
      if (result["senderId"].toString() !=
              FirebaseAuth.instance.currentUser.uid &&
          (result["isread"] == null ||
              result["isread"] == "N" ||
              result["isread"] == "U")) {
        dt["isread"] = "Y";
        FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.roomModel.roomId.toString())
            .collection("messages")
            .doc(result.id)
            .update(dt);
      }
    }
  }

  Widget bottomNavigationBar() {
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Stack(
      children: [
        Image.asset(
          "assets/chat_bg.png",
          height: 15,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Container(
          height: show ? 356 : keyboardHeight + 56,
          //keyboardHeight + int.parse(show ? "356" : "56"),
          color: Colors.transparent,
          // padding: EdgeInsets.only(bottom: 5, left: 5, right: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                // mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width - 60,
                          child: Stack(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: TextFormField(
                                  controller: _controller,
                                  focusNode: focusNode,
                                  //textAlignVertical: TextAlignVertical.center,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 2,
                                  minLines: 1,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Send Emoji",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.only(left: 50),
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                padding:
                                    const EdgeInsets.only(top: 3, left: 5),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.emoji_emotions_outlined,
                                    color:
                                        show ? Colors.lightBlue : Colors.grey,
                                  ),
                                  onPressed: () {
                                    if (!show) {
                                      focusNode.unfocus();
                                      focusNode.canRequestFocus = false;
                                    }
                                    setState(() {
                                      show = !show;
                                    });
                                  },
                                ),
                              )
                            ],
                          )),
                      Container(
                        padding: const EdgeInsets.only(
                            bottom: 5, right: 5, left: 2, top: 1),
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: const Color(0xFF128C7E),
                          child: IconButton(
                            alignment: Alignment.center,
                            icon: const Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              sendMessage();
                              // _scrollController.animateTo(
                              //     _scrollController.position.maxScrollExtent,
                              //     duration: Duration(milliseconds: 300),
                              //     curve: Curves.easeOut);
                              _controller.clear();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  show ? emojiSelect() : Container(),
                ],
              ),
              SizedBox(
                  height: show ? 0 : MediaQuery.of(context).viewInsets.bottom)
            ],
          ),
        )
      ],
    );
  }

  Widget emojiSelect() {
    return SizedBox(
      height: 300,
      child: EmojiPicker(
          onEmojiSelected: (Category category, Emoji emoji) {
            _onEmojiSelected(emoji);
          },
          onBackspacePressed: _onBackspacePressed,
          config: Config(
              columns: 7,
              emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
              verticalSpacing: 0,
              horizontalSpacing: 0,
              initCategory: Category.RECENT,
              bgColor: const Color(0xFFF2F2F2),
              indicatorColor: Colors.blue,
              iconColor: Colors.grey,
              iconColorSelected: Colors.blue,
              progressIndicatorColor: Colors.blue,
              backspaceColor: Colors.blue,
              skinToneDialogBgColor: Colors.white,
              skinToneIndicatorColor: Colors.grey,
              enableSkinTones: true,
              showRecentsTab: true,
              recentsLimit: 28,
              noRecentsText: 'No Recents',
              noRecentsStyle:
                  const TextStyle(fontSize: 20, color: Colors.black26),
              tabIndicatorAnimDuration: kTabScrollDuration,
              categoryIcons: const CategoryIcons(),
              buttonMode: ButtonMode.MATERIAL)),
    );
  }

  sendMessage() async {
    if (_controller.text.isEmpty) {
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(const SnackBar(content: Text("Enter message")));
      return;
    }
    final myUserID = FirebaseAuth.instance.currentUser.uid;
    String message = _controller.text;

    String notificationMessage = message.length > 50
        ? message.replaceRange(50, message.length, '...')
        : message;

    MessageModel messageModel = MessageModel();
    messageModel.message = message;
    messageModel.isread = "N";
    await chatsCollectionReferance.add(messageModel.toMap());

    Map<String, dynamic> roomMap = Map();
    roomMap['lastMessage'] = message;
    roomMap['timeStamp'] = FieldValue.serverTimestamp();

    await FirebaseFirestore.instance
        .collection("rooms")
        .doc(widget.roomModel.roomId)
        .update(roomMap);
    // notif.Notification notification = notif.Notification();
    // notification.showNotification(message);
    _controller.clear();
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    DocumentSnapshot variable = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.roomModel.peerId == myUserID
            ? widget.roomModel.senderId
            : widget.roomModel.peerId)
        .get();
    Map<String, dynamic> userData = variable.data() as Map<String, dynamic>;

    PushNotifications.sendNotification(
        title: userData["Contactlist"][_userDetails["mobileNo"]] ??
            _userDetails["mobileNo"],
        message: notificationMessage,
        chatID: widget.roomModel.senderId == myUserID
            ? widget.roomModel.peerId
            : widget.roomModel.senderId,
        userID: myUserID,
        notificationToken: widget.userModel.notificationtoken,
        roomID: widget.roomModel.roomId,
      status: userData['status']
    );
  }
}
