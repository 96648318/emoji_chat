import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/message_model.dart';
import '../utilities.dart';

class ChatItem extends StatelessWidget {
  MessageModel messageModel;

  ChatItem(this.messageModel, {Key key}) : super(key: key);

  bool left = false;

  @override
  Widget build(BuildContext context) {
    if (messageModel.senderId == FirebaseAuth.instance.currentUser.uid) {
      left = false;
      if (messageModel.senderId != FirebaseAuth.instance.currentUser.uid) {}
    } else {
      left = true;
    }
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          children: [
            Row(
              mainAxisAlignment:
                  left ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                SizedBox(width: left ? 5 : 0),
                Flexible(flex: left ? 0 : 25, child: Container()),
                Flexible(
                  flex: 75,
                  child: Container(
                    decoration: BoxDecoration(
                      color: left ? Colors.green[300] : Colors.red[300],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(left ? 0 : 15),
                        bottomRight: Radius.circular(left ? 15 : 0),
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Text(
                        messageModel.message ?? "",
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
                Flexible(flex: left ? 25 : 0, child: Container()),
                SizedBox(width: left ? 0 : 5)
              ],
            ),
            const SizedBox(height: 1),
            Row(
              mainAxisAlignment:
                  left ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                SizedBox(width: left ? 5 : 0),
                Align(
                    alignment:
                        left ? Alignment.bottomLeft : Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: left ? 5 : 0, right: left ? 0 : 5),
                      child: Text(
                        messageModel.timeStamp != null
                            ? Utilities.displayTimeAgoFromTimestamp(
                                messageModel.timeStamp.toDate().toString())
                            : "",
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                      ),
                    )),
                left
                    ? Container()
                    : Align(
                        alignment: Alignment.bottomRight,
                        child: messageModel.isread == "Y"
                            ? const Icon(
                                Icons.done_all,
                                size: 14,
                                color: Colors.blue,
                              )
                            : messageModel.isread == "U"
                                ? const Icon(
                                    Icons.done_all,
                                    size: 14,
                                  )
                                : const Icon(
                                    Icons.done,
                                    size: 14,
                                  ),
                      ),
                SizedBox(width: left ? 0 : 5)
              ],
            )
          ],
        ));
  }

// Row(
//   mainAxisAlignment:
//       left ? MainAxisAlignment.start : MainAxisAlignment.end,
//   children: [
//     Card(
//       elevation: 1,
//       shape:
//           RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       child: Container(
//         width: MediaQuery.of(context).size.width / 1.5,
//         padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.all(Radius.circular(8)),
//             color: left ? Colors.grey : AppColors.lightprimary),
//         child: Column(
//           crossAxisAlignment:
//               left ? CrossAxisAlignment.start : CrossAxisAlignment.end,
//           children: [
//             Text(
//               messageModel.message ?? "",
//               style: TextStyle(color: Colors.white, fontSize: 20),
//             ),
//             SizedBox(
//               height: 6,
//             ),
//             Align(
//               alignment: Alignment.bottomRight,
//               child: Text(
//                 messageModel.timeStamp != null
//                     ? Utilities.displayTimeAgoFromTimestamp(
//                         messageModel.timeStamp.toDate().toString())
//                     : "",
//                 style: TextStyle(color: Colors.white, fontSize: 12),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   ],
// ),

}
