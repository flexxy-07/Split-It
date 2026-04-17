import 'package:flutter/material.dart';
import 'package:split_it/theme/app_colors.dart';
import '../../domain/entities/group_entity.dart';

class GroupCard extends StatelessWidget {
  final GroupEntity group;
  final String currentUserId;

  const GroupCard({
    super.key,
    required this.group,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final net = group.netBalanceForUser(currentUserId);
    final isPositive = net >= 0;
    final isSettled = net == 0;
    final balanceColor = isSettled
        ? Colors.white.withOpacity(0.3)
        : isPositive
            ? AppColors.positive
            : AppColors.negative;

    return GestureDetector(
      onTap: () {
        // TODO: navigate to group detail — Phase 3
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
        child: Row(
          children: [
            // Group avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: Center(
                child: Text(
                  group.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Group info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${group.memberIds.length} member${group.memberIds.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Balance pill
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: balanceColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: balanceColor.withOpacity(0.2),
                ),
              ),
              child: Text(
                isSettled
                    ? 'settled'
                    : '${isPositive ? '+' : '-'}₹${net.abs().toStringAsFixed(0)}',
                style: TextStyle(
                  color: balanceColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}