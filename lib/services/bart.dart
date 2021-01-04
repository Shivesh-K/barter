import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

enum BartStatus { BARTED, ACTIVE }

class Bart {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  static final _storage = FirebaseStorage.instance;

  String title;
  String description;
  List<File> photos;
  GeoFirePoint location;

  static Future<DocumentReference> create({
    String title,
    String description,
    List<File> photos,
    GeoFirePoint location,
  }) async {
    // Get reference to a new document
    DocumentReference ref = _db.collection('barts').doc();
    // Upload all the image files.
    final uploadUrls = await _uploadImages(ref, photos);

    // If there is any problem in uploading, return null
    if (uploadUrls == null || uploadUrls.length < 1) {
      return null;
    }

    try {
      await ref.set({
        'title': title,
        'description': description,
        'photoUrls': uploadUrls,
        'location': location.data,
        'author': {
          'name': _auth.currentUser.displayName,
          'uid': _auth.currentUser.uid,
          'ref': _db.collection('users').doc(_auth.currentUser.uid)
        },
        'status': BartStatus.ACTIVE.index,
      }, SetOptions(merge: true));

      return ref;
    } catch (e) {
      return null;
    }
  }

  static Future<List<String>> _uploadImages(
      DocumentReference docRef, List<File> photos) async {
    StorageReference ref =
        _storage.ref().child('${_auth.currentUser.uid}/${docRef.id}/');

    List<String> uploadUrls = [];
    int i = 0;

    await Future.wait(
      photos.map((File image) async {
        StorageReference reference = ref.child('${i++}');
        StorageUploadTask uploadTask = reference.putFile(image);
        StorageTaskSnapshot storageTaskSnapshot;

        StorageTaskSnapshot snapshot = await uploadTask.onComplete;
        if (snapshot.error == null) {
          storageTaskSnapshot = snapshot;
          final String downloadUrl =
              await storageTaskSnapshot.ref.getDownloadURL();
          uploadUrls.add(downloadUrl);

          print('Upload success');
        } else {
          return null;
        }
      }),
      eagerError: true,
      cleanUp: (_) {
        print('eager cleaned up');
      },
    );

    return uploadUrls;
  }
}
