class MatchJoinRequest {
  final String id;
  final String matchId;
  final int requesterId;
  final String requesterName;
  final String status;
  final List<int> approvedByUserIds;
  final int requiredApprovals;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const MatchJoinRequest({
    required this.id,
    required this.matchId,
    required this.requesterId,
    required this.requesterName,
    required this.status,
    required this.approvedByUserIds,
    required this.requiredApprovals,
    required this.createdAt,
    this.resolvedAt,
  });

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  int get approvalsCount => approvedByUserIds.length;
}
