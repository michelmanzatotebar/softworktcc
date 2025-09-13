// lib/models/chat_models.dart

class ChatUser {
  final String id;
  final String firstName;
  final String lastName;

  ChatUser({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  String get fullName => '$firstName $lastName'.trim();
  String get initials => firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  static ChatUser fromMap(Map<String, dynamic> map) {
    return ChatUser(
      id: map['id']?.toString() ?? '',
      firstName: map['firstName']?.toString() ?? '',
      lastName: map['lastName']?.toString() ?? '',
    );
  }
}

class ChatMessage {
  final String id;
  final String text;
  final String authorId;
  final DateTime createdAt;
  final String type;

  ChatMessage({
    required this.id,
    required this.text,
    required this.authorId,
    required this.createdAt,
    this.type = 'text',
  });

  bool isAuthor(String userId) => authorId == userId;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'authorId': authorId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'type': type,
    };
  }

  static ChatMessage fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      authorId: map['authorId']?.toString() ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      type: map['type']?.toString() ?? 'text',
    );
  }
}

class ChatRoom {
  final String id;
  final String name;
  final List<String> userIds;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  ChatRoom({
    required this.id,
    required this.name,
    required this.userIds,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'userIds': userIds,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.millisecondsSinceEpoch,
    };
  }

  static ChatRoom fromMap(String roomId, Map<String, dynamic> map) {
    return ChatRoom(
      id: roomId,
      name: map['name']?.toString() ?? '',
      userIds: List<String>.from(map['userIds'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastMessage: map['lastMessage']?.toString(),
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime'])
          : null,
    );
  }
}