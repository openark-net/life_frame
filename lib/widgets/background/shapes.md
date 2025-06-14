# 90s Abstract Shapes Widget Reference

## ZigZagShape
```dart
ZigZagShape({
  double width = 100,
  double height = 20,
  Color color = Color(0xFF00CED1),
  double rotation = 0,
  double shadowOffset = 4,
  double lineWidth = 8,
  int segments = 3,
})
```

## CircleShape
```dart
CircleShape({
  double size = 60,
  Color color = Color(0xFF00CED1),
  double shadowOffset = 4,
})
```

## TriangleShape
```dart
TriangleShape({
  double size = 60,
  Color color = Color(0xFF00FF00),
  double rotation = 0,
  double shadowOffset = 4,
  double cornerRadius = 8,
})
```

## StraightLineShape
```dart
StraightLineShape({
  double width = 80,
  double height = 16,
  Color color = Color(0xFFFFA500),
  double rotation = 0,
  double shadowOffset = 4,
})
```

## SquareShape
```dart
SquareShape({
  double size = 60,
  Color color = Color(0xFF00FF00),
  double rotation = 0,
  double shadowOffset = 4,
  double cornerRadius = 8,
})
```

## SquigglyLineShape
```dart
SquigglyLineShape({
  double width = 100,
  double height = 20,
  Color color = Color(0xFFFF1493),
  double rotation = 0,
  double shadowOffset = 4,
  double lineWidth = 8,
  int waves = 3,
})
```

### Notes
- All shapes include a black shadow offset
- `rotation` is in radians
- All shapes have rounded edges/corners
- Colors can be any Flutter `Color` object