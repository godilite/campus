import 'package:camp/models/user_account.dart';
import 'package:camp/views/auth/account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:camp/main.dart';

class AuthService {
  FirebaseAuth auth = FirebaseAuth.instance;
  final userReference = FirebaseFirestore.instance.collection("users");
  final usernameReference = FirebaseFirestore.instance.collection("username");
  final DateTime timestamp = DateTime.now();

  Future signInWithFacebook() async {
    try {
      final facebookLogin = FacebookLogin();
      final facebookLoginResult = await facebookLogin.logIn(['email']);
      final token = facebookLoginResult.accessToken.token;

      // Create a credential from the access token
      final FacebookAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(token);
      UserCredential user =
          await auth.signInWithCredential(facebookAuthCredential);
      // Once signed in, return the UserCredential
      return await _createAccount(user);
    } on FirebaseAuthException catch (e) {
      String email = e.email;
      if (e.code == 'account-exists-with-different-credential') {
        // Fetch a list of what sign-in methods exist for the conflicting user
        List<String> userSignInMethods =
            await auth.fetchSignInMethodsForEmail(email);

        if (userSignInMethods.first == 'google.com') {
          var result = {'error': e, 'method': 'google.com'};
          return result;
        }

        if (userSignInMethods.first == 'password') {
          var result = {'error': e, 'method': 'password'};
          return result;
        }
      }
    } catch (e) {}
  }

  Future signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      var user = await auth.signInWithCredential(credential);

      return await _createAccount(user);
    } on FirebaseAuthException catch (e) {
      String email = e.email;
      if (e.code == 'account-exists-with-different-credential') {
        // Fetch a list of what sign-in methods exist for the conflicting user
        List<String> userSignInMethods =
            await auth.fetchSignInMethodsForEmail(email);

        if (userSignInMethods.first == 'facebook.com') {
          var result = {'error': e, 'method': 'facebook.com'};
          return result;
        }
        if (userSignInMethods.first == 'password') {
          var result = {'error': e, 'method': 'password'};
          return result;
        }
      }
    }
  }

  Future createWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: "barry.allen@example.com", password: "SuperSecretPassword!");
      return await _createAccount(userCredential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      String email = e.email;
      if (e.code == 'account-exists-with-different-credential') {
        // Fetch a list of what sign-in methods exist for the conflicting user
        List<String> userSignInMethods =
            await auth.fetchSignInMethodsForEmail(email);

        if (userSignInMethods.first == 'google.com') {
          var result = {'error': e, 'method': 'google.com'};
          return result;
        }

        if (userSignInMethods.first == 'facebook.com') {
          var result = {'error': e, 'method': 'facebook.com'};
          return result;
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void logout() {
    auth.signOut();
  }

  //Account Linking methods
  Future<UserCredential> linkWithFacebook(pendingCredential) async {
    final facebookLogin = FacebookLogin();
    final facebookLoginResult = await facebookLogin.logIn(['email']);
    String token = facebookLoginResult.accessToken.token;

    FacebookAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(token);

    // Sign the user in with the credential
    UserCredential userCredential =
        await auth.signInWithCredential(facebookAuthCredential);

    // Link the pending credential with the existing account

    await userCredential.user.linkWithCredential(pendingCredential);

    // Success! Go back to your application flow
    return userCredential;
  }

  Future<UserCredential> linkWithGoogle(pendingCredential) async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    // Create a new credential
    final GoogleAuthCredential googleCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign the user in with the credential
    UserCredential userCredential =
        await auth.signInWithCredential(googleCredential);

    // Link the pending credential with the existing account
    await userCredential.user.linkWithCredential(pendingCredential);
    return userCredential;
  }

  Future<UserCredential> linkWithPassword(
      email, String password, pendingCredential) async {
    // Prompt the user to enter their password

    // Sign the user in to their account with the password
    UserCredential userCredential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Link the pending credential with the existing account
    await userCredential.user.linkWithCredential(pendingCredential);

    // Success! Go back to your application flow
    return userCredential;
  }

  Future<UserAccount> _createAccount(UserCredential user) async {
    DocumentSnapshot documentSnapshot =
        await userReference.doc(user.user.uid).get();

    if (!documentSnapshot.exists) {
      final userData = await navigatorKey.currentState
          .push(MaterialPageRoute(builder: (context) => CreateAccount()));

      userReference.doc(user.user.uid).set({
        'id': user.user.uid,
        'name': userData.displayName,
        'username': userData.username,
        'email': user.user.email,
        'profileUrl': user.user.photoURL,
        'phone': userData.phone,
        'bio': '',
        'coverPhoto': '',
        'timestamp': timestamp
      });

      documentSnapshot = await userReference.doc(user.user.uid).get();
    }

    return UserAccount.fromData(documentSnapshot);
  }

  Future<bool> checkifUsernameExist(String username) async {
    DocumentSnapshot usernameSnapshot =
        await usernameReference.doc(username).get();
    if (usernameSnapshot.exists) return false;

    return true;
  }
}
