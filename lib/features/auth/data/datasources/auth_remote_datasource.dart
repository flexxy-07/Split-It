import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:split_it/features/auth/data/models/user_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });

  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail({required String email});

  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  const AuthRemoteDatasourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
      _firestore = firestore,
      _googleSignIn = googleSignIn;

  @override
  // TODO: implement authStateChanges
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if(firebaseUser == null) return null;
      try {
        return await _getUserFromFirestore(firebaseUser.uid);
      } catch(_) {
        return null;
      }
    });
  }
  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if(firebaseUser == null) return null;
      return await _getUserFromFirestore(
        firebaseUser.uid
      );
    }catch(e) {
      throw ServerException(message : e.toString());
    }
  }  

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);

    }on FirebaseAuthException catch(e){
      throw ServerException(message : e.message ?? 'Failed to send password reset email');
    }catch(e){
      throw ServerException(message : e.toString());
    }
  }

  @override
  Future<UserModel> signInWithEmail({required String email, required String password}) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      final user = credential.user!;
      return await _getUserFromFirestore(user.uid) ?? UserModel.fromFirebaseUser(id: user.uid, email: user.email!, name: user.displayName);

    }on FirebaseAuthException catch(e){
      throw ServerException(
        message : e.message ?? 'Auth failed', statusCode : null
      );
    }catch(e){
      throw ServerException(message : e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try{
      final googleUser = await _googleSignIn.authenticate();

      // auth tokens
      final googleAuth  = googleUser.authentication;

      // creating firebase creds with google tokens
      final creds = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // signIn to firebase with google creds
      final userCredential = await _firebaseAuth.signInWithCredential(creds);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw const ServerException(message: 'Google Sign-In failed');
      }

      // check if user already exists in firestore
      final existingUser = await _getUserFromFirestore(firebaseUser.uid);

      if(existingUser != null) return existingUser;

      // first time google login, create firestore document 
      final userModel = UserModel.fromFirebaseUser(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        name: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
      );

      await _saveUserToFirestore(userModel);
      return userModel; 
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const ServerException(message: 'Google Sign-In cancelled');
      }
      throw ServerException(message: e.description ?? 'Google Sign In failed');
    } on FirebaseAuthException catch (e){
      throw ServerException(message : e.message ??  'Google Sign In failed');
    }on ServerException {
      rethrow;
    }catch (e){
      throw ServerException(message : e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // signOut from both firebase and Google simultaneously
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    }catch (e){
      throw ServerException(message : e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmail({required String email, required String password, required String name}) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

      final firebaseUser = credential.user!;
      await firebaseUser.updateDisplayName(name);

      final userModel = UserModel.fromFirebaseUser(id: firebaseUser.uid, email: email, name: name);

      await _saveUserToFirestore(userModel);
      return userModel;
    } on FirebaseAuthException catch(e){
      throw ServerException(
        message: e.message ?? 'Sign up failed',
        statusCode : int.tryParse(e.code),
      );
    }catch(e){
      throw ServerException(message : e.toString());
    }
  }

  // Helpers
  Future<UserModel?> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if(!doc.exists || doc.data() == null) return null;
    return UserModel.fromJson({
      ...doc.data()!, 'id' : doc.id
    });
  }

  Future<void> _saveUserToFirestore(UserModel model) async {
    await _firestore.collection('users').doc(model.id).set(model.toJson(), SetOptions(merge : true));
  }

}