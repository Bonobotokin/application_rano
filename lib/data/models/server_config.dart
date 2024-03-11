class ServerConfig {
  final String baseUrl;

  ServerConfig({required this.baseUrl});

  factory ServerConfig.fromJson(Map<String, dynamic> json) {
    return ServerConfig(
      baseUrl: json['baseUrl'],
    );
  }
}
