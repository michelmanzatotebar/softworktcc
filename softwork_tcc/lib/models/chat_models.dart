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
  final String status; // 'sending', 'sent', 'delivered', 'read'

  ChatMessage({
    required this.id,
    required this.text,
    required this.authorId,
    required this.createdAt,
    this.type = 'text',
    this.status = 'sending',
  });

  bool isAuthor(String userId) => authorId == userId;

  String get timeFormatted {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(createdAt.year, createdAt.month, createdAt.day);

    if (messageDate == today) {
      // Hoje - mostrar apenas hora
      return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    } else {
      // Outro dia - mostrar data e hora
      return '${createdAt.day}/${createdAt.month} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'authorId': authorId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'type': type,
      'status': status,
    };
  }

  static ChatMessage fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      authorId: map['authorId']?.toString() ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      type: map['type']?.toString() ?? 'text',
      status: map['status']?.toString() ?? 'sent',
    );
  }

  // Método para atualizar status
  ChatMessage copyWith({String? status}) {
    return ChatMessage(
      id: id,
      text: text,
      authorId: authorId,
      createdAt: createdAt,
      type: type,
      status: status ?? this.status,
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