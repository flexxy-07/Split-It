import 'package:split_it/features/auth/domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? upiId;
  final int friendshipScore;
  final String scoreTitle;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.upiId,
    required this.friendshipScore,
    required this.scoreTitle,
    required this.createdAt,
  });

  // from firestore map to model
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? json['name'] as String
          : (json['email'] as String?)?.split('@').first ?? 'User',
      email: (json['email'] as String?) ?? '',
      friendshipScore: (json['friendshipScore'] as num?)?.toInt() ?? 50,
      scoreTitle: json['scoreTitle'] as String? ?? 'New Member',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['createdAt'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  // userModel -> FireStore map
  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'upiId': upiId,
      'friendshipScore': friendshipScore,
      'scoreTitle': scoreTitle,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // firebase user -> UserModel #for New SignUps
  factory UserModel.fromFirebaseUser({
    required String id,
    required String email,
    String? name,
    String? photoUrl,
  }){
    return UserModel(id: id, name: name ?? email.split('@').first, email: email, friendshipScore: 50, scoreTitle: 'New Memb er', createdAt: DateTime.now(), photoUrl: photoUrl);
  }

  // UserMode;l -> UserEntity
  UserEntity toEntity(){
    return UserEntity(
      id: id,
      name: name,
      email: email,
      photoUrl: photoUrl,
      upiId: upiId,
      friendshipScore: friendshipScore,
      scoreTitle: scoreTitle,
      createdAt: createdAt,
    );
  }
}
