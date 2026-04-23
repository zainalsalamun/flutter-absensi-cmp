import 'dart:convert';

class RecognitionEmbedding {
  final String id;
  final String name;
  final List<double> embedding;

  RecognitionEmbedding({
    required this.id,
    required this.name,
    required this.embedding,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'embedding': embedding,
    };
  }

  factory RecognitionEmbedding.fromMap(Map<String, dynamic> map) {
    return RecognitionEmbedding(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      embedding: List<double>.from(map['embedding'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory RecognitionEmbedding.fromJson(String source) =>
      RecognitionEmbedding.fromMap(json.decode(source));
}
