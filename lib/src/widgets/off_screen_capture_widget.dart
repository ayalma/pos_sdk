import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:pos_sdk/src/models/models.dart';

class OffScreenCaptureWidget extends StatefulWidget {
  final Widget child;
  final Widget capture;
  OffScreenCaptureWidget({
    Key key,
    @required this.child,
    @required this.capture,
  })  : assert(child != null),
        assert(capture != null),
        super(key: key);

  @override
  OffScreenCaptureWidgetState createState() => OffScreenCaptureWidgetState();


  static OffScreenCaptureWidgetState of(BuildContext context, { bool nullOk = false }) {
    assert(nullOk != null);
    assert(context != null);

    final OffScreenCaptureWidgetState result = context.findAncestorStateOfType<OffScreenCaptureWidgetState>();
    if (nullOk || result != null)
      return result;
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
        'OffScreenCaptureWidget.of() called with a context that does not contain a OffScreenCaptureWidget.'
      ),
      ErrorDescription(
        'No OffScreenCaptureWidget ancestor could be found starting from the context that was passed to OffScreenCaptureWidget.of(). '
        'This usually happens when the context provided is from the same StatefulWidget as that '
        'whose build function actually creates the OffScreenCaptureWidget widget being sought.'
      ),
      ErrorHint(
        'There are several ways to avoid this problem. The simplest is to use a Builder to get a '
        'context that is "under" the OffScreenCaptureWidget'
      ),
      ErrorHint(
        'A more efficient solution is to split your build function into several widgets. This '
        'introduces a new context from which you can obtain the Scaffold. In this solution, '
        'you would have an outer widget that creates the OffScreenCaptureWidget populated by instances of '
        'your new inner widgets, and then in these inner widgets you would use Scaffold.of().\n'
        'A less elegant but more expedient solution is assign a GlobalKey to the OffScreenCaptureWidget, '
        'then use the key.currentState property to obtain the OffScreenCaptureWidgetState rather than '
        'using the OffScreenCaptureWidget.of() function.'
      ),
      context.describeElement('The context used was')
    ]);
  }
}

class OffScreenCaptureWidgetState extends State<OffScreenCaptureWidget> {
 final _boundaryKey = GlobalKey();

  Future<CaptureResult> captureImage() async {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final boundary =
        _boundaryKey.currentContext.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);

    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return CaptureResult(data.buffer.asUint8List(), image.width, image.height,image);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final height = constraints.maxHeight;
        return Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            widget.child,
            Positioned(
              left: 0.0,
              right: 0.0,
              top: height,
              height: height,
              child: Center(
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: widget.capture,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
