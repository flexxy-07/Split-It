import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:split_it/core/error/exceptions.dart';
import 'package:split_it/features/groups/data/models/group_model.dart';

abstract class GroupRemoteDatasource {
  Future<GroupModel> createGroup({
    required String name,
    required String createdByUserId,
  });

  Stream<List<GroupModel>> watchUserGroups(String userId);

  Future<GroupModel> getGroup(String groupId);

  Future<void> addMemberByEmail({
    required String groupId,
    required String email,
  });

  Future<void> removeMember({required String groupId, required String userId});

  Future<void> deleteGroup(String groupId);
}

class GroupRemoteDatasourceImpl implements GroupRemoteDatasource {
  final FirebaseFirestore _firestore;

  const GroupRemoteDatasourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<GroupModel> createGroup({
    required String name,
    required String createdByUserId,
  }) async {
    try {
      final data = {
        'name': name,
        'createdByUserId': createdByUserId,
        'memberIds': [createdByUserId],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'imageUrl': null,
      };

      final docRef = await _firestore.collection('groups').add(data);
      // write the auto generated ID back into the document
      await docRef.update({'id': docRef.id});

      return GroupModel.fromJson({...data, 'id': docRef.id});
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to create group ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Stream<List<GroupModel>> watchUserGroups(String userId) {
    return _firestore
        .collection('groups')
        .where('memberIds', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => GroupModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        )
        .handleError((error) {
          throw ServerException(message: error.toString());
        });
  }

  @override
  Future<GroupModel> getGroup(String groupId) async {
    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();

      if(!doc.exists || doc.data() == null){
        throw const ServerException(message: 'Group not found');
      }
      return GroupModel.fromJson({...doc.data()!, 'id' : doc.id});
    } on FirebaseException catch(e) {
      throw ServerException(message: e.message ?? 'Failed to get group');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> addMemberByEmail({
    required String groupId,
    required String email,
  }) async {
    try {
      final userQuery = await _firestore.collection('users').where('email', isEqualTo: email).limit(1).get();

      if(userQuery.docs.isEmpty){
        throw const ServerException(message: 
        'No user found with this email. They need to sign up first.');
      }

      final userId = userQuery.docs.first.id;


      // Checking if they are not already a member

      final groupDoc = await _firestore.collection('groups').doc(groupId).get();

      final members = List<String>.from(groupDoc.data()?['memberIds'] as List? ?? []);


      if(members.contains(userId)){
        throw const ServerException(message: 'This person is already in the group.');
      }

      // add them using arrayUnion, no duplicates possible

    await _firestore.collection('groups').doc(groupId).update({
      'memeberIds' : FieldValue.arrayUnion([userId])
    });
    } on FirebaseException catch(e) {
      throw ServerException(message: e.message ?? 'Failed to add member');
    } on ServerException {
      rethrow;
    }catch(e){
      throw ServerException(message: e.toString());
    }

    
  }

  @override
  Future<void> removeMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      await _firestore.collection('groups').doc(groupId).update({
        'memberIds' : FieldValue.arrayRemove([userId]),
      });
    } on FirebaseException catch(e) {
      throw ServerException(message: e.message ?? 'Failed to remove member');
    }catch(e) {
      throw ServerException(message: e.toString());
    }
  }


  @override
  Future<void> deleteGroup(String groupId) async {
    try {
      await _firestore.collection('groups').doc(groupId).delete();
    } on FirebaseException catch(e){
      throw ServerException(message: e.message ?? 'failed to delete Group');
    }catch (e){
      throw ServerException(message: e.toString());
    }
  }
}
