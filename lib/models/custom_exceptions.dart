class NotFoundException implements Exception {
  String? message;

  NotFoundException({this.message});

  @override
  String toString() {
    return message ?? '';
  }
}

class ServerDownException implements Exception {
  String? message;

  ServerDownException({this.message});

  @override
  String toString() {
    return message ?? '';
  }
}

class ChannelsNotFoundException implements Exception {
  String? message;

  ChannelsNotFoundException({this.message});

  @override
  String toString() {
    return message ?? '';
  }
}