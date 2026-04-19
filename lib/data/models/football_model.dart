class Football {
  final int id;
  final String name;
  final String league;
  final String createdAt;

  Football({
    required this.id,
    required this.name,
    required this.league,
    required this.createdAt,
  });

  factory Football.fromJson(Map<String, dynamic> json) {
    return Football(
      id: json['id'],
      name: json['name'],
      league: json['league'],
      createdAt: json['created_at'],
    );
  }
}