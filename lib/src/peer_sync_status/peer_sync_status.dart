class SyncStatus {
  final String id;
  final bool isDittoServer;
  final String syncSessionStatus;
  final int? syncedUpToLocalCommitId;
  final int? lastUpdateReceivedTime;

  SyncStatus({
    required this.id,
    required this.isDittoServer,
    required this.syncSessionStatus,
    this.syncedUpToLocalCommitId,
    this.lastUpdateReceivedTime,
  });

  factory SyncStatus.fromJson(Map<String, dynamic> json) {
    // The data comes back with fields inside a 'documents' object
    final documents = json['documents'] as Map<String, dynamic>? ?? {};
    
    var syncStatusRaw = documents['sync_session_status'];
    
    // Convert to string for consistent handling
    String syncStatus = '';
    if (syncStatusRaw != null) {
      if (syncStatusRaw is num) {
        // If it's a number, 1 = connected, 0 = not connected
        syncStatus = syncStatusRaw == 1 ? 'Connected' : 'Not Connected';
      } else {
        syncStatus = syncStatusRaw.toString();
      }
    }
    
    final syncedCommitId = documents['synced_up_to_local_commit_id'];
    final lastUpdateTime = documents['last_update_received_time'];
    
    return SyncStatus(
      id: json['_id'] ?? '',
      isDittoServer: json['is_ditto_server'] ?? false,
      syncSessionStatus: syncStatus,
      syncedUpToLocalCommitId: (syncedCommitId as num?)?.toInt(),
      lastUpdateReceivedTime: (lastUpdateTime as num?)?.toInt(),
    );
  }

  bool get isConnected => syncSessionStatus == 'Connected';
  
  String get peerType => isDittoServer ? 'Cloud Server' : 'Peer Device';
  
  bool get hasSyncedCommit => syncedUpToLocalCommitId != null;
  
  bool get hasLastUpdateTime => lastUpdateReceivedTime != null;
}