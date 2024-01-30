import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:username_generator/username_generator.dart';

class SignInProvider extends ChangeNotifier {
  //instance of firebaseauth, facebook and google
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  var generator = UsernameGenerator();

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  //hasError, errorCode, provider, uid, email, name, imageUrl, username
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _provider;
  String? get provider => _provider;

  String? _uid;
  String? get uid => _uid;

  String? _email;
  String? get email => _email;

  String? _name;
  String? get name => _name;

  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  String? _username;
  String? get username => _username;

  bool? _firstRun;
  bool? get firstRun => _firstRun;

  SignInProvider() {
    checkSignInUser();
  }

  Future checkSignInUser() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("signed_in") ?? false;
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("signed_in", true);
    _isSignedIn = true;
    notifyListeners();
  }

  Future<DocumentReference> insertUsername(String username, String uid) async {
    // Get the Firestore instance
    var firestore = FirebaseFirestore.instance;
    // Get the collection reference for 'users'
    var usersRef = firestore.collection('usernames');
    // Get the document reference for the username
    var docRef = usersRef.doc(username);
    // Set the document data with the username field
    await docRef.set({'uname': username, 'uid': uid});
    // Return the document reference
    return docRef;
  }

  // This function takes no parameters and returns a String value
// It uses the username_generator package to generate a random username
// It also checks if the username is already taken in the Firestore users collection
// If the username is taken, it tries again until it finds an available one
// It returns the final username as a String
  Future<String> createRandomUsername() async {
    // Get the Firestore instance
    var firestore = FirebaseFirestore.instance;

    // Declare a variable to store the username
    var username;

    // Declare a boolean variable to store the availability status
    var available = false;

    // Loop until the username is available
    while (!available) {
      // Generate a random username using the package
      username = generator.generateRandom();

      // Get the document reference for the username
      var docRef = firestore.collection('users').doc(username);

      // Get the document snapshot
      var docSnap = await docRef.get();

      // Check if the document exists or not
      if (docSnap.exists) {
        available = false;
      } else {
        available = true;
      }
    }

    return username;
  }

  // sign in with google
  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      //excute login
      try {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credentials = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // signing into firebase
        final User userDetails =
            (await firebaseAuth.signInWithCredential(credentials)).user!;

        // now save all values
        _name = userDetails.displayName;
        _email = userDetails.email;
        _uid = userDetails.uid;
        _imageUrl = userDetails.photoURL;
        _provider = "google";
        notifyListeners();

        await createRandomUsername().then((value) {
          _username = value;
          insertUsername(_username!, _uid!);
        });
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode = "Already connected with a different service";
            _hasError = true;
            notifyListeners();
            break;
          case "null":
            _errorCode = "Unexpected error has happened";
            _hasError = true;
            notifyListeners();
            break;
          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  // Entry for clouddfirestore
  Future getUserDataFromFirestore([String? uid]) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get()
        .then((DocumentSnapshot snapshot) => {
              _uid = snapshot['id'],
              _name = snapshot['name'],
              _email = snapshot['email'],
              _imageUrl = snapshot['image_url'],
              _provider = snapshot['provider'],
              _firstRun = snapshot['firstRun'],
              _username = snapshot['username']
            });
  }

  Future saveDatatoFirestore() async {
    final DocumentReference r =
        FirebaseFirestore.instance.collection("users").doc(uid);
    await r.set({
      "id": _uid,
      "name": _name,
      "username": _username,
      "email": _email,
      "profileId": 0,
      "image_url": _imageUrl,
      "provider": _provider,
      "verified": false,
      "joinedAt": DateTime.now().toString(),
      "createdAt": Timestamp.now(),
      "isSubscribed": false,
      "firstRun": false,
    });
    notifyListeners();
  }

  Future saveDatatoSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString('name', _name!);
    await s.setString('email', _email!);
    await s.setString('username', _username!);
    await s.setString('uid', _uid!);
    await s.setString('imageUrl', _imageUrl!);
    await s.setString('provider', _provider!);
    await s.setBool('firstRun', false);
    notifyListeners();
  }

  Future getDataFromSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _name = s.getString('name');
    _username = s.getString('username');
    _email = s.getString('email');
    _uid = s.getString('uid');
    _imageUrl = s.getString('imageUrl');
    _provider = s.getString('provider');
    _firstRun = s.getBool('firstRun');
    notifyListeners();
  }

  // checkuser exists or not in clouddfirestore
  Future<bool> checkuserExists() async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    if (snap.exists) {
      print("User Exists");
      return true;
    } else {
      print("NEW USER");
      return false;
    }
  }

  Future<bool> checkUsername(String username) async {
    var firestore = FirebaseFirestore.instance;
    var docRef = firestore.collection('users').doc(username);
    var docSnap = await docRef.get();

    if (docSnap.exists) {
      return false;
    } else {
      return true;
    }
  }

  // signout
  Future userSignOut() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();

    _isSignedIn = false;
    notifyListeners();

    // clear all storage information
    clearStoredData();
  }

  Future clearStoredData() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.clear();
  }
}
