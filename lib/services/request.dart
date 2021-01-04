import 'package:barter/services/bart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum RequestStatus { WAITING, ACCEPTED, REJECTED }

class Request {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<DocumentReference> createRequest({
    DocumentSnapshot forSnap,
    Set<DocumentSnapshot> selectedSnaps,
    DocumentReference toRef,
    DocumentReference fromRef,
  }) async {
    // If the any of the reference is null or they are equal, then return null
    if (toRef == null || fromRef == null || toRef == fromRef) return null;

    // If the request for the same bart from the same user already exists, return null
    if (await Request.exists(forSnap.id, _auth.currentUser.uid)) return null;

    try {
      // Create a document and set all the data
      final newRef = _db.collection('requests').doc();
      await newRef.set({
        'for': {'id': forSnap.id, 'ref': forSnap.reference},
        'against': selectedSnaps
            .map((e) => ({'id': e.id, 'ref': e.reference}))
            .toList(),
        'to': {'id': toRef.id, 'ref': toRef},
        'from': {'id': fromRef.id, 'ref': fromRef},
        'status': RequestStatus.WAITING.index,
        'id': newRef.id,
      });

      return newRef;
    } catch (e) {
      // If there is any error, simply return null
      return null;
    }
  }

  static Future<bool> exists(String forId, String fromId) async {
    if ((await _db
                .collection('requests')
                .where('for.id', isEqualTo: forId)
                .where('from.id', isEqualTo: fromId)
                .get())
            .size >
        0) return true;
    return false;
  }

  static Future<bool> acceptRequest(DocumentSnapshot forSnap,
      DocumentSnapshot againstSnap, DocumentSnapshot reqSnap) async {
    final batch = _db.batch();

    try {
      batch.update(againstSnap.reference, {'status': BartStatus.BARTED.index});
      batch.update(forSnap.reference, {'status': BartStatus.BARTED.index});
      batch.update(reqSnap.reference, {
        'status': RequestStatus.ACCEPTED.index,
        'against': {'id': againstSnap.id, 'ref': againstSnap.reference}
      });
      batch.commit();
      return true;
    } catch (e) {
      print("There was an error!");
      return false;
    }
  }

  static Future<bool> rejectRequest(DocumentSnapshot reqSnap) async {
    try {
      await reqSnap.reference.update({
        'status': RequestStatus.REJECTED.index,
      });
      return true;
    } catch (e) {
      print("There was an error!");
      return false;
    }
  }
}
