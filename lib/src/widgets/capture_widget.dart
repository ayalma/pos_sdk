import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:pos_sdk/src/models/models.dart';

class CaptureWidget extends StatefulWidget {
  final Widget child;
  CaptureWidget({Key key, @required this.child})
      : assert(child != null),
        super(key: key);

  @override
  CaptureWidgetState createState() => CaptureWidgetState();
  static CaptureWidgetState of(BuildContext context, { bool nullOk = false }) {
    assert(nullOk != null);
    assert(context != null);

    final CaptureWidgetState result = context.findAncestorStateOfType<CaptureWidgetState>();
    if (nullOk || result != null)
      return result;
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
        'CaptureWidget.of() called with a context that does not contain a CaptureWidget.'
      ),
      ErrorDescription(
        'No CaptureWidget ancestor could be found starting from the context that was passed to CaptureWidget.of(). '
        'This usually happens when the context provided is from the same StatefulWidget as that '
        'whose build function actually creates the CaptureWidget widget being sought.'
      ),
      ErrorHint(
        'There are several ways to avoid this problem. The simplest is to use a Builder to get a '
        'context that is "under" the CaptureWidget'
      ),
      ErrorHint(
        'A more efficient solution is to split your build function into several widgets. This '
        'introduces a new context from which you can obtain the Scaffold. In this solution, '
        'you would have an outer widget that creates the CaptureWidget populated by instances of '
        'your new inner widgets, and then in these inner widgets you would use Scaffold.of().\n'
        'A less elegant but more expedient solution is assign a GlobalKey to the CaptureWidget, '
        'then use the key.currentState property to obtain the CaptureWidgetState rather than '
        'using the CaptureWidget.of() function.'
      ),
      context.describeElement('The context used was')
    ]);
  }
}

class CaptureWidgetState extends State<CaptureWidget> {
  GlobalKey _boundaryKey;
  @override
  void initState() {
    super.initState();
    _boundaryKey = GlobalKey();
  }

  Future<CaptureResult> captureImage() async {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final boundary =
        _boundaryKey.currentContext.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return CaptureResult(data.buffer.asUint8List(), image.width, image.height,image);
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        key: _boundaryKey,
        child: widget.child,
      );
}
