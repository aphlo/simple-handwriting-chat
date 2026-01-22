import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'l10n/app_localizations.dart';

const String termsOfServiceUrl = 'https://example.com/terms';
const String privacyPolicyUrl = 'https://example.com/privacy';

void main() => runApp(const SimpleHandwritingChatApp());

class SimpleHandwritingChatApp extends StatelessWidget {
  const SimpleHandwritingChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Handwriting Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MirrorDrawingPage(),
    );
  }
}

enum Pane { top, bottom }

class StrokePoint {
  StrokePoint(this.offset);
  final Offset offset;
}

class Stroke {
  Stroke({required this.pointerId, required this.points});
  final int pointerId;
  final List<StrokePoint> points;

  Stroke copyWith({List<StrokePoint>? points}) {
    return Stroke(pointerId: pointerId, points: points ?? this.points);
  }
}

class MirrorDrawingPage extends StatefulWidget {
  const MirrorDrawingPage({super.key});

  @override
  State<MirrorDrawingPage> createState() => _MirrorDrawingPageState();
}

class _MirrorDrawingPageState extends State<MirrorDrawingPage> {
  final List<Stroke> _strokes = [];
  final Map<int, Stroke> _activeStrokes = {};
  final List<List<Stroke>> _undoHistory = [];

  Color _strokeColor = const Color(0xFF1B7F3A);
  double _strokeWidth = 6.0;

  Offset _toCanonical(Offset local, double width, double height, Pane pane) {
    if (pane == Pane.bottom) return local;
    return Offset(width - local.dx, height - local.dy);
  }

  void _onPointerDown(
    PointerDownEvent event,
    double width,
    double height,
    Pane pane,
  ) {
    final canonical = _toCanonical(event.localPosition, width, height, pane);
    final stroke = Stroke(
      pointerId: event.pointer,
      points: [StrokePoint(canonical)],
    );
    _activeStrokes[event.pointer] = stroke;
    _strokes.add(stroke);
    setState(() {});
  }

  void _onPointerMove(
    PointerMoveEvent event,
    double width,
    double height,
    Pane pane,
  ) {
    final stroke = _activeStrokes[event.pointer];
    if (stroke == null) return;

    final canonical = _toCanonical(event.localPosition, width, height, pane);

    final last = stroke.points.isNotEmpty ? stroke.points.last.offset : null;
    if (last != null && (canonical - last).distance < 1.5) return;

    stroke.points.add(StrokePoint(canonical));
    setState(() {});
  }

  void _onPointerUp(PointerUpEvent event) {
    final stroke = _activeStrokes.remove(event.pointer);
    if (stroke != null && stroke.points.length >= 2) {
      _undoHistory.add(
        _strokes.map((s) => s.copyWith(points: List.from(s.points))).toList(),
      );
      if (_undoHistory.length > 50) {
        _undoHistory.removeAt(0);
      }
    }
    setState(() {});
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _activeStrokes.remove(event.pointer);
    setState(() {});
  }

  void _undo() {
    if (_undoHistory.isEmpty) return;
    _strokes.clear();
    if (_undoHistory.length > 1) {
      _undoHistory.removeLast();
      _strokes.addAll(_undoHistory.last);
    } else {
      _undoHistory.clear();
    }
    setState(() {});
  }

  void _clear() {
    if (_strokes.isNotEmpty) {
      _undoHistory.add(
        _strokes.map((s) => s.copyWith(points: List.from(s.points))).toList(),
      );
    }
    _strokes.clear();
    _activeStrokes.clear();
    setState(() {});
  }

  void _showSettings() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settings,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Text(l10n.strokeColor),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: [
                    const Color(0xFF1B7F3A),
                    const Color(0xFF2196F3),
                    const Color(0xFFF44336),
                    const Color(0xFF9C27B0),
                    const Color(0xFFFF9800),
                    const Color(0xFF000000),
                  ].map((color) {
                    return GestureDetector(
                      onTap: () {
                        setModalState(() {
                          _strokeColor = color;
                        });
                        setState(() {});
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: _strokeColor == color
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: _strokeColor == color
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Text(l10n.strokeWidth(_strokeWidth.toStringAsFixed(1))),
                Slider(
                  value: _strokeWidth,
                  min: 2.0,
                  max: 20.0,
                  onChanged: (value) {
                    setModalState(() {
                      _strokeWidth = value;
                    });
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openMenu() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MenuPage()),
    );
  }

  Widget _buildDrawingPane({required Pane pane}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (e) => _onPointerDown(e, width, height, pane),
          onPointerMove: (e) => _onPointerMove(e, width, height, pane),
          onPointerUp: (e) => _onPointerUp(e),
          onPointerCancel: (e) => _onPointerCancel(e),
          child: Container(
            color: const Color(0xFFF7F5EE),
            child: CustomPaint(
              painter: MirrorPainter(
                strokes: _strokes,
                flipBothXY: pane == Pane.top,
                strokeColor: _strokeColor,
                strokeWidth: _strokeWidth,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: _buildDrawingPane(pane: Pane.top)),
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _undoHistory.isEmpty ? null : _undo,
                  icon: const Icon(Icons.undo),
                  tooltip: l10n.undo,
                  iconSize: 28,
                ),
                IconButton(
                  onPressed: _strokes.isEmpty ? null : _clear,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.clear,
                  iconSize: 28,
                ),
                IconButton(
                  onPressed: _showSettings,
                  icon: const Icon(Icons.settings),
                  tooltip: l10n.settings,
                  iconSize: 28,
                ),
                IconButton(
                  onPressed: _openMenu,
                  icon: const Icon(Icons.menu),
                  tooltip: l10n.menu,
                  iconSize: 28,
                ),
              ],
            ),
          ),
          Expanded(child: _buildDrawingPane(pane: Pane.bottom)),
        ],
      ),
    );
  }
}

class MirrorPainter extends CustomPainter {
  MirrorPainter({
    required this.strokes,
    required this.flipBothXY,
    required this.strokeColor,
    required this.strokeWidth,
  });

  final List<Stroke> strokes;
  final bool flipBothXY;
  final Color strokeColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.save();

    if (flipBothXY) {
      canvas.translate(size.width, size.height);
      canvas.scale(-1, -1);
    }

    for (final stroke in strokes) {
      if (stroke.points.length < 2) continue;

      final path = Path()
        ..moveTo(stroke.points.first.offset.dx, stroke.points.first.offset.dy);

      for (int i = 1; i < stroke.points.length; i++) {
        final p = stroke.points[i].offset;
        path.lineTo(p.dx, p.dy);
      }

      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MirrorPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.flipBothXY != flipBothXY ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  void _openWebView(BuildContext context, String title, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(title: title, url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.menu),
      ),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final version = snapshot.hasData
              ? '${snapshot.data!.version}+${snapshot.data!.buildNumber}'
              : '';

          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(l10n.termsOfService),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openWebView(
                  context,
                  l10n.termsOfService,
                  termsOfServiceUrl,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n.privacyPolicy),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openWebView(
                  context,
                  l10n.privacyPolicy,
                  privacyPolicyUrl,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.article_outlined),
                title: Text(l10n.licenses),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'Simple Handwriting Chat',
                    applicationVersion: version,
                  );
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.version(version),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({
    super.key,
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: _progress < 1.0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(value: _progress),
              )
            : null,
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
        onProgressChanged: (controller, progress) {
          setState(() {
            _progress = progress / 100;
          });
        },
      ),
    );
  }
}
