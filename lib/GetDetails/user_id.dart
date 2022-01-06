import 'package:firebase_auth/firebase_auth.dart';

class GetUserID{

  Future<String> getUserID() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser _user = await _auth.currentUser();
    return _user.uid;
  }
}