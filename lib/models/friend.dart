import 'package:flutter/material.dart';

class Friend {
  final String id; // 고유 식별자 추가
  final String name;
  final Color color;

  Friend({required this.id, required this.name, required this.color});

  Map<String, dynamic> toJson() => {
    'id': id,  // id도 JSON에 포함
    'name': name,
    'color': color.value,
  };

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
    id: json['id'] ?? '',  // id가 null일 경우 빈 문자열 사용
    name: json['name'] ?? '',  // name이 null일 경우 빈 문자열 사용
    color: Color(json['color'] as int),  // color는 int로 형변환
  );
}
 
