class PointNode {
  int index;
  double x;
  double y;
  double angle; // radians internally
  double time;

  PointNode({
    required this.index,
    required this.x,
    required this.y,
    required this.angle,
    required this.time,
  });
  
  // Convert from JSON
  factory PointNode.fromJson(Map<String, dynamic> json) {
    return PointNode(
      index: json['index'] as int,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      angle: (json['angle'] as num).toDouble(),
      time: (json['time'] as num).toDouble(),
    );
  }

  // Convert to JSON 
  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'x': x,
      'y': y,
      'angle': angle,
      'time': time,
    };
  }

  // Create a copy with optional modifications
  PointNode copyWith({
    int? index,
    double? x,
    double? y,
    double? angle,
    double? time,
  }) {
    return PointNode(
      index: index ?? this.index,
      x: x ?? this.x,
      y: y ?? this.y,
      angle: angle ?? this.angle,
      time: time ?? this.time,
    );
  }
}