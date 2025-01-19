class Username {
  final String username;
  final String uuid;
  final bool isWhite; 

  const Username({
    required this.username,
    required this.uuid,
    required this.isWhite,
  });

  factory Username.fromRTDB(Map<String, dynamic> data) {
    return Username(
      username: data['username'] ?? '',
      uuid: data['uuid'] ?? '',
      isWhite: data['white'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'uuid': uuid,
      'white': isWhite,
    };
  }

  Username copyWith({
    String? username,
    String? uuid,
    bool? isWhite,
  }) {
    return Username(
      username: username ?? this.username,
      uuid: uuid ?? this.uuid,
      isWhite: isWhite ?? this.isWhite,
    );
  }
}




