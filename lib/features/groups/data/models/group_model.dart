// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:split_it/features/groups/domain/entities/group_entity.dart';

class GroupModel {
  final String id;
  final String name;
  final String createdByUserId;
  final List<String> memberIds;
  final Map<String, double> balances;
  final DateTime createdAt;
  final String? imageUrl;

  GroupModel({
    required this.id,
    required this.name,
    required this.createdByUserId,
    required this.memberIds,
    required this.balances,
    required this.createdAt,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdByUserId': createdByUserId,
      'memeberIds': memberIds,
      'balances': balances,
      'createdAt': createdAt,
      'imageUrl': imageUrl,
    };
  }

  GroupEntity toEntity() {
    return GroupEntity(
      id: id,
      name: name,
      createdByUserId: createdByUserId,
      memberIds: memberIds,
      balances: balances,
      createdAt: createdAt,
    );
  }

  factory GroupModel.fromEntity(GroupEntity entity) {
    return GroupModel(
      id: entity.id,
      name: entity.name,
      createdByUserId: entity.createdByUserId,
      memberIds: entity.memberIds,
      balances: entity.balances,
      createdAt: entity.createdAt,
      imageUrl: entity.imageUrl,
    );
  }

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdByUserId: json['createdByUserId'] as String,
      memberIds: List<String>.from(
        (json['memberIds'] ?? json['memeberIds'] ?? []) as List,
      ),
      balances: (json['balances'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          ) ??
          {},
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt'] as DateTime
          : json['createdAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
              : DateTime.parse(json['createdAt'] as String),
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
