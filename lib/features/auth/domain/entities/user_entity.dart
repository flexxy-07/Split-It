class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? upiId;
  final int friendshipScore;
  final String scoreTitle;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.upiId,
    this.friendshipScore = 50,
    this.scoreTitle = 'New Member',
    required this.createdAt,
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? upiId,
    int? friendshipScore,
    String? scoreTitle,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      upiId: upiId ?? this.upiId,
      friendshipScore: friendshipScore ?? this.friendshipScore,
      scoreTitle: scoreTitle ?? this.scoreTitle,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
