// Copied from the SDK and hand-tweaked a bit

part of "presence_viewer.dart";

Map<String, dynamic> _$PresenceGraphToJson(PresenceGraph instance) =>
    <String, dynamic>{
      'localPeer': _$PeerToJson(instance.localPeer),
      'remotePeers': instance.remotePeers.map(_$PeerToJson).toList(),
    };

Map<String, dynamic> _$PeerToJson(Peer instance) => <String, dynamic>{
      'peerKeyString': instance.peerKey,
      'deviceName': instance.deviceName,
      'os': instance.os,
      'isConnectedToDittoCloud': instance.isConnectedToDittoServer,
      'isCompatible': instance.isCompatible,
      'dittoSdkVersion': instance.dittoSdkVersion,
      'connections': instance.connections.map(_$ConnectionToJson).toList(),
      'peerMetadata': instance.peerMetadata,
      'identityServiceMetadata': instance.identityServiceMetadata,
    };

Map<String, dynamic> _$ConnectionToJson(Connection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'peerKeyString1': instance.peer1,
      'peerKeyString2': instance.peer2,
      'connectionType': _$ConnectionTypeEnumMap[instance.connectionType]!,
    };

const _$ConnectionTypeEnumMap = {
  ConnectionType.bluetooth: 'Bluetooth',
  ConnectionType.accessPoint: 'AccessPoint',
  ConnectionType.p2pWifi: 'P2PWifi',
  ConnectionType.webSocket: 'WebSocket',
};
