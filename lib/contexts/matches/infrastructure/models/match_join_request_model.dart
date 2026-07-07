import '../../domain/entities/match_join_request.dart';

class MatchJoinRequestModel extends MatchJoinRequest {
  const MatchJoinRequestModel({
    required super.id,
    required super.matchId,
    required super.requesterId,
    required super.requesterName,
    required super.status,
    required super.approvedByUserIds,
    required super.requiredApprovals,
    required super.createdAt,
    super.resolvedAt,
  });

  factory MatchJoinRequestModel.fromJson(Map<String, dynamic> json) {
    final requesterJson = json['requester'] as Map<String, dynamic>? ?? {};
    final approvedByList = json['approvedBy'] as List<dynamic>? ?? [];

    return MatchJoinRequestModel(
      id: json['id'].toString(),
      matchId: json['matchId'].toString(),
      requesterId: requesterJson['id'] as int? ?? 0,
      requesterName: requesterJson['name'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      approvedByUserIds: approvedByList
          .map((e) => (e as Map<String, dynamic>)['id'] as int? ?? 0)
          .toList(),
      requiredApprovals: json['requiredApprovals'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
    );
  }
}
