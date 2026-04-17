// ignore_for_file: public_member_api_docs, sort_constructors_first
class GroupEntity {
  final String id;
  final String name;
  final String createdByUserId;
  final List<String> memberIds;
  final Map<String, double> balances;
  final DateTime createdAt;
  final String? imageUrl;

  GroupEntity({
    required this.id,
    required this.name,
    required this.createdByUserId,
    required this.memberIds,
    required this.balances,
    required this.createdAt,
    this.imageUrl,
  });


  // how much you personally owe or are owed in this group
  // Post : Other owe you, Neg : you owe to othet
  //

  double netBalanceForUser(String userId){
    double net = 0;
    balances.forEach((key, val){
      final parts = key.split('_');
      if(parts[0] == userId) net -= val; // you owe to others
      if(parts[1] == userId) net += val; // owed to you
    });
    return net;

  } 

  GroupEntity copyWith({
    String? id,
    String? name,
    String? createdByUserId,
    List<String>? memberIds,
    Map<String, double>? balances,
    DateTime? createdAt,
    String? imageUrl,
  }) {
    return GroupEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      memberIds: memberIds ?? this.memberIds,
      balances: balances ?? this.balances,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
