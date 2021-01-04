import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  static final _db = FirebaseFirestore.instance;

  static Future<bool> exists(String id1, String id2) async {
    final String id = id1.compareTo(id2) < 0 ? '$id1-$id2' : '$id2-$id1';
    return (await _db.collection('chats').doc(id).get()).exists;
  }

  static Future<DocumentReference> create(String id1, String id2) async {
    if (id1.compareTo(id2) == 0) return null;

    bool isFirstLess = id1.compareTo(id2) < 0;

    DocumentReference user1, user2;
    user1 = _db.collection('users').doc(isFirstLess ? id1 : id2);
    user2 = _db.collection('users').doc(isFirstLess ? id2 : id1);

    final String chatId = '${user1.id}-${user2.id}';

    await _db.runTransaction((t) {
      t.set(_db.collection('chats').doc(chatId), {
        'user1': {
          'id': user1.id,
          'ref': user1,
        },
        'user2': {
          'id': user2.id,
          'ref': user2,
        },
      });
      t.set(
        _db.collection('users').doc(user1.id).collection('chats').doc(chatId),
        {'ref': _db.collection('chats').doc(chatId), 'peerRef': user2},
      );
      t.set(
        _db.collection('users').doc(user2.id).collection('chats').doc(chatId),
        {'ref': _db.collection('chats').doc(chatId), 'peerRef': user1},
      );
      return;
    });

    return _db.collection('chats').doc(chatId);
  }
}
