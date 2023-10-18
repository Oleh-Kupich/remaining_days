import 'package:flutter/material.dart';

import 'package:remaining_days/widgets/bottom_bar_widget/controller.dart';

/// An enum representing different sides of a screen
enum Side { top, bottom }

/// Bottom app bar with an animated, expandable content body
class BottomExpandableAppBar extends StatefulWidget {

  const BottomExpandableAppBar({
    super.key,
    this.expandedBody,
    this.expandedHeight,
    this.horizontalMargin = 16,
    this.bottomOffset = 10,
    this.shape,
    this.appBarHeight = kToolbarHeight,
    this.attachSide = Side.bottom,
    this.constraints,
    this.bottomAppBarColor,
    this.appBarDecoration,
    this.bottomAppBarBody,
    this.expandedBackColor,
    this.expandedDecoration,
    this.controller,
    this.notchMargin = 5,
  })  : assert(!(expandedBackColor != null && expandedDecoration != null));
  /// The content visible when the [BottomExpandableAppBar]
  /// is expanded
  final Widget? expandedBody;

  /// The height of the expanded [BottomExpandableAppBar]
  final double? expandedHeight;

  /// The content of the bottom app bar
  final Widget? bottomAppBarBody;

  /// A [BottomBarController] to use with the
  /// [BottomExpandableAppBar]
  final BottomBarController? controller;

  /// A [Side] which determines which side of the
  /// screen the panel is attached to
  final Side attachSide;

  /// Height of the bottom app bar
  final double appBarHeight;

  final double notchMargin;

  /// [BoxConstraints] which determines the final height
  /// of the panel
  final BoxConstraints? constraints;

  /// [NotchedShape] shape for a [FloatingActionButton]
  final NotchedShape? shape;

  /// Background [Color] for the panel
  final Color? expandedBackColor;

  /// [Color] of the bottom app bar
  final Color? bottomAppBarColor;

  /// Margin on the horizontal axis
  /// for the bottom app bar content
  final double horizontalMargin;

  /// Offset for the content from
  /// the bottom of the bottom app bar
  final double bottomOffset;

  /// [Decoration] for the panel container
  final Decoration? expandedDecoration;

  /// [Decoration] for the bottom app bar
  final Decoration? appBarDecoration;

  @override
  State<BottomExpandableAppBar> createState() => _BottomExpandableAppBarState();
}

class _BottomExpandableAppBarState extends State<BottomExpandableAppBar> {
  BottomBarController? _controller;
  late double panelState;

  void _handleBottomBarControllerAnimationTick() {
    if (_controller!.state.value == panelState) return;
    panelState = _controller!.state.value;
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateBarController();
    panelState = _controller!.state.value;
  }

  @override
  void didUpdateWidget(BottomExpandableAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) _updateBarController();
  }

  @override
  void dispose() {
    _controller?.state.removeListener(_handleBottomBarControllerAnimationTick);
    // We don't own the _controller Animation, so it's not disposed here.
    super.dispose();
  }

  void _updateBarController() {
    final newController = widget.controller ?? DefaultBottomBarController.of(context);

    if (newController == _controller) return;

    if (_controller != null) {
      _controller!.state.removeListener(_handleBottomBarControllerAnimationTick);
    }

    _controller = newController;

    if (_controller != null) {
      _controller!.state.addListener(_handleBottomBarControllerAnimationTick);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewPadding = widget.attachSide == Side.bottom
        ? EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom)
        : EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top);

    return LayoutBuilder(
      builder: (context, layoutConstraints) {
        final constraints = widget.constraints ??
            layoutConstraints.deflate(
              EdgeInsets.only(
                top: kToolbarHeight * 1.5,
                bottom: widget.appBarHeight,
              ),
            );

        final finalHeight = widget.expandedHeight ?? constraints.maxHeight - viewPadding.vertical;

        _controller!.dragLength = finalHeight;

        return Stack(
          alignment: widget.attachSide == Side.bottom ? Alignment.bottomCenter : Alignment.topCenter,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.horizontalMargin),
              child: Stack(
                children: [
                  Container(
                      height:
                          panelState * finalHeight + widget.appBarHeight + widget.bottomOffset + viewPadding.vertical,
                      decoration: widget.expandedDecoration ??
                          BoxDecoration(
                            color: widget.expandedBackColor ?? Theme.of(context).colorScheme.background,
                            borderRadius: BorderRadius.circular(25),
                          ),
                      child: widget.expandedBody,),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
