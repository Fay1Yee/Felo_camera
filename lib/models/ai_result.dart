import 'dart:ui';

class AIResult {
  final String title;       // e.g., '体检报告' / '眼部区域' / '出行箱视角'
  final int confidence;     // 0–100
  final String? subInfo;    // e.g., '可添加健康标记' / '电量: 85%'
  final Rect? bbox;         // relative 0~1; optional for health mode

  const AIResult({
    required this.title,
    required this.confidence,
    this.subInfo,
    this.bbox,
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
    return AIResult(
      title: map['title'] as String? ?? '',
      confidence: (map['confidence'] as num?)?.toInt() ?? 0,
      subInfo: map['subInfo'] as String?,
      bbox: bbox,
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
      };

  @override
  String toString() =>
      'AIResult(title: $title, confidence: $confidence, subInfo: $subInfo, bbox: $bbox)';
}