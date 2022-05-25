// To parse this JSON data, do
//
//     final empty = emptyFromJson(jsonString);

import 'dart:convert';

List<Empty> emptyFromJson(String str) => List<Empty>.from(json.decode(str).map((x) => Empty.fromJson(x)));

String emptyToJson(List<Empty> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Empty {
    Empty({
        required this.availability,
        required this.polygon1,
        required this.polygon2,
        required this.polygon3,
        required this.polygon4,
        required this.polygon5,
        required this.polygon6,
        required this.polygon7,
        required this.polygon8,
        required this.polygon9,
        required this.polygon10,
        required this.type,
    });

    String availability;
    String polygon1;
    String polygon2;
    String polygon3;
    String polygon4;
    String polygon5;
    String polygon6;
    String polygon7;
    String polygon8;
    String polygon9;
    String polygon10;
    String type;

    factory Empty.fromJson(Map<String, dynamic> json) => Empty(
        availability: json["availability"],
        polygon1: json["polygon1"],
        polygon2: json["polygon2"],
        polygon3: json["polygon3"],
        polygon4: json["polygon4"],
        polygon5: json["polygon5"],
        polygon6: json["polygon6"],
        polygon7: json["polygon7"],
        polygon8: json["polygon8"],
        polygon9: json["polygon9"],
        polygon10: json["polygon10"],
        type: json["type"],
    );

    Map<String, dynamic> toJson() => {
        "availability": availability,
        "polygon1": polygon1,
        "polygon2": polygon2,
        "polygon3": polygon3,
        "polygon4": polygon4,
        "polygon5": polygon5,
        "polygon6": polygon6,
        "polygon7": polygon7,
        "polygon8": polygon8,
        "polygon9": polygon9,
        "polygon10": polygon10,
        "type": type,
    };
}
