import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String> getImageUrl(String path) async {
    try {
      Reference ref = storage.ref().child(path);
      String url = await ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      // 예외 처리 로직을 여기에 추가합니다.
      // 예를 들어, 로그를 남기거나 사용자에게 오류 메시지를 표시할 수 있습니다.
      print(e);
      return Future.error('Image load failed: ${e.code}');
    }
  }
}

class ApiService {
  // 리스트 추출.
  Future<List<String>> getCelebrityList() async {
    final celebritiesRef = FirebaseFirestore.instance.collection('celebrity');
    final querySnapshot = await celebritiesRef.get();
    final celebrityList = List<String>.from(
        querySnapshot.docs.first.data()['celebrities'] as List<dynamic>);
    return celebrityList;
  }
}
