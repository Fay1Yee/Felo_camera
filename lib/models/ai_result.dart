import 'dart:ui';

/// 单个活动事件模型
class ActivityEvent {
  final String title;
  final String content;
  final DateTime timestamp;
  final String category;
  final double confidence;
  final List<String> tags;
  final Map<String, dynamic> metadata;

  const ActivityEvent({
    required this.title,
    required this.content,
    required this.timestamp,
    required this.category,
    required this.confidence,
    this.tags = const [],
    this.metadata = const {},
  });

  factory ActivityEvent.fromJson(Map<String, dynamic> json) {
    return ActivityEvent(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String),
      category: json['category'] as String? ?? 'other',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      tags: List<String>.from(json['tags'] as List? ?? []),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'category': category,
        'confidence': confidence,
        'tags': tags,
        'metadata': metadata,
      };

  @override
  String toString() =>
      'ActivityEvent(title: $title, category: $category, timestamp: $timestamp)';
}

class AIResult {
  final String title;       // e.g., '体检报告' / '眼部区域' / '出行箱视角'
  final int confidence;     // 0–100
  final String? subInfo;    // e.g., '可添加健康标记' / '电量: 85%'
  final Rect? bbox;         // relative 0~1; optional for health mode
  final List<ActivityEvent>? multipleEvents; // 支持多个活动事件

  const AIResult({
    required this.title,
    required this.confidence,
    this.subInfo,
    this.bbox,
    this.multipleEvents,
  });

  factory AIResult.fromJson(Map<String, dynamic> map) {
    Rect? bbox;
    final b = map['bbox'];
    if (b is Map<String, dynamic>) {
      final x = (b['x'] as num?)?.toDouble() ?? 0.0;
      final y = (b['y'] as num?)?.toDouble() ?? 0.0;
      final w = (b['w'] as num?)?.toDouble() ?? 0.0;
      final h = (b['h'] as num?)?.toDouble() ?? 0.0;
      bbox = Rect.fromLTWH(x, y, w, h);
    }
    
    List<ActivityEvent>? multipleEvents;
    final eventsData = map['multipleEvents'];
    if (eventsData is List) {
      multipleEvents = eventsData
          .map((eventData) => ActivityEvent.fromJson(eventData as Map<String, dynamic>))
          .toList();
    }
    
    return AIResult(
      title: map['title'] as String? ?? '',
      confidence: (map['confidence'] as num?)?.toInt() ?? 0,
      subInfo: map['subInfo'] as String?,
      bbox: bbox,
      multipleEvents: multipleEvents,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'confidence': confidence,
        if (subInfo != null) 'subInfo': subInfo,
        if (bbox != null)
          'bbox': {
            'x': bbox!.left,
            'y': bbox!.top,
            'w': bbox!.width,
            'h': bbox!.height,
          },
        if (multipleEvents != null)
          'multipleEvents': multipleEvents!.map((event) => event.toJson()).toList(),
      };

  @override
  String toString() =>
      'AIResult(title: $title, confidence: $confidence, subInfo: $subInfo, bbox: $bbox)';
}