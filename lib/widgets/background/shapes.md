# 90s Abstract Shapes Widget Reference

## ZigZagShape
**File:** `lib/widgets/background/zigzag_shape.dart`
```dart
ZigZagShape({
  double width = 100,
  double height = 20,
  Color color = Color(0xFF00CED1),
  double rotation = 0,
  double shadowOffset = 4,
  double lineWidth = 8,
  int segments = 3,
  double opacity = 1.0,
})
```

## CircleShape
**File:** `lib/widgets/background/circle_shape.dart`
```dart
CircleShape({
  double size = 60,
  Color color = Color(0xFF00CED1),
  double shadowOffset = 4,
  double opacity = 1.0,
})
```

## TriangleShape
**File:** `lib/widgets/background/triangle_shape.dart`
```dart
TriangleShape({
  double size = 60,
  Color color = Color(0xFF00FF00),
  double rotation = 0,
  double shadowOffset = 4,
  double cornerRadius = 8,
  double opacity = 1.0,
})
```

## StraightLineShape
**File:** `lib/widgets/background/straight_line_shape.dart`
```dart
StraightLineShape({
  double width = 80,
  double height = 16,
  Color color = Color(0xFFFFA500),
  double rotation = 0,
  double shadowOffset = 4,
  double opacity = 1.0,
})
```

## SquareShape
**File:** `lib/widgets/background/square_shape.dart`
```dart
SquareShape({
  double size = 60,
  Color color = Color(0xFF00FF00),
  double rotation = 0,
  double shadowOffset = 4,
  double cornerRadius = 8,
  double opacity = 1.0,
})
```

## SquigglyLineShape
**File:** `lib/widgets/background/squiggly_line_shape.dart`
```dart
SquigglyLineShape({
  double width = 100,
  double height = 20,
  Color color = Color(0xFFFF1493),
  double rotation = 0,
  double shadowOffset = 4,
  double lineWidth = 8,
  int waves = 3,
  double opacity = 1.0,
})
```

### Notes
- All shapes include a black shadow offset
- `rotation` is in radians
- All shapes have rounded edges/corners
- Colors can be any Flutter `Color` object
- `opacity` controls the transparency of both the shape and its shadow (0.0 = transparent, 1.0 = opaque)