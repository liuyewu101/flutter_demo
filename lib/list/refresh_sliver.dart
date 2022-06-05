import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';


class _CupertinoSliverRefresh extends SingleChildRenderObjectWidget {
  const _CupertinoSliverRefresh({
    Key? key,
    this.refreshIndicatorLayoutExtent = 0.0,
    this.hasLayoutExtent = false,
    Widget? child,
  }) : assert(refreshIndicatorLayoutExtent >= 0.0),
        super(key: key, child: child);

  final double refreshIndicatorLayoutExtent;

  final bool hasLayoutExtent;

  @override
  _RenderCupertinoSliverRefresh createRenderObject(BuildContext context) {
    return _RenderCupertinoSliverRefresh(
      refreshIndicatorExtent: refreshIndicatorLayoutExtent,
      hasLayoutExtent: hasLayoutExtent,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant _RenderCupertinoSliverRefresh renderObject) {
    renderObject
      ..refreshIndicatorLayoutExtent = refreshIndicatorLayoutExtent
      ..hasLayoutExtent = hasLayoutExtent;
  }
}

class _RenderCupertinoSliverRefresh extends RenderSliver
    with RenderObjectWithChildMixin<RenderBox> {
  _RenderCupertinoSliverRefresh({
    required double refreshIndicatorExtent,
    required bool hasLayoutExtent,
    RenderBox? child,
  }) : assert(refreshIndicatorExtent >= 0.0),
        _refreshIndicatorExtent = refreshIndicatorExtent,
        _hasLayoutExtent = hasLayoutExtent {
    this.child = child;
  }

  double get refreshIndicatorLayoutExtent => _refreshIndicatorExtent;
  double _refreshIndicatorExtent;
  set refreshIndicatorLayoutExtent(double value) {
    assert(value >= 0.0);
    if (value == _refreshIndicatorExtent)
      return;
    _refreshIndicatorExtent = value;
    markNeedsLayout();
  }

  bool get hasLayoutExtent => _hasLayoutExtent;
  bool _hasLayoutExtent;
  set hasLayoutExtent(bool value) {
    if (value == _hasLayoutExtent)
      return;
    _hasLayoutExtent = value;
    markNeedsLayout();
  }

  double layoutExtentOffsetCompensation = 0.0;

  @override
  void performLayout() {
    assert(constraints.axisDirection == AxisDirection.down);
    assert(constraints.growthDirection == GrowthDirection.forward);

    final double layoutExtent =
        (_hasLayoutExtent ? 1.0 : 0.0) * _refreshIndicatorExtent;
    if (layoutExtent != layoutExtentOffsetCompensation) {
      geometry = SliverGeometry(
        scrollOffsetCorrection: layoutExtent - layoutExtentOffsetCompensation,
      );
      layoutExtentOffsetCompensation = layoutExtent;
      return;
    }

    final bool active = constraints.overlap < 0.0 || layoutExtent > 0.0;
    final double overscrolledExtent =
    constraints.overlap < 0.0 ? constraints.overlap.abs() : 0.0;
    child!.layout(
      constraints.asBoxConstraints(
        maxExtent: layoutExtent
            + overscrolledExtent,
      ),
      parentUsesSize: true,
    );
    if (active) {
      geometry = SliverGeometry(
        scrollExtent: layoutExtent,
        paintOrigin: -overscrolledExtent - constraints.scrollOffset,
        paintExtent: max(
          max(child!.size.height, layoutExtent) - constraints.scrollOffset,
          0.0,
        ),
        maxPaintExtent: max(
          max(child!.size.height, layoutExtent) - constraints.scrollOffset,
          0.0,
        ),
        layoutExtent: max(layoutExtent - constraints.scrollOffset, 0.0),
      );
    } else {
      geometry = SliverGeometry.zero;
    }
  }

  @override
  void paint(PaintingContext paintContext, Offset offset) {
    if (constraints.overlap < 0.0 ||
        constraints.scrollOffset + child!.size.height > 0) {
      paintContext.paintChild(child!, offset);
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) { }
}

enum MyRefreshIndicatorMode {

  inactive,

  drag,

  armed,

  refresh,

  done,
}

typedef RefreshControlIndicatorBuilder = Widget Function(
    BuildContext context,
    MyRefreshIndicatorMode? refreshState,
    double pulledExtent,
    double refreshTriggerPullDistance,
    double refreshIndicatorExtent,
    );


typedef RefreshCallback = Future<void> Function();

class MyCupertinoSliverRefreshControl extends StatefulWidget {

  const MyCupertinoSliverRefreshControl({
    Key? key,
    this.refreshTriggerPullDistance = _defaultRefreshTriggerPullDistance,
    this.refreshIndicatorExtent = _defaultRefreshIndicatorExtent,
    this.builder = buildSimpleRefreshIndicator,
    this.onRefresh,
  }) : assert(refreshTriggerPullDistance > 0.0),
        assert(refreshIndicatorExtent >= 0.0),
        assert(
        refreshTriggerPullDistance >= refreshIndicatorExtent,
        ),
        super(key: key);


  final double refreshTriggerPullDistance;

  final double refreshIndicatorExtent;

  final RefreshControlIndicatorBuilder builder;

  final RefreshCallback? onRefresh;

  static const double _defaultRefreshTriggerPullDistance = 100.0;
  static const double _defaultRefreshIndicatorExtent = 60.0;

  @visibleForTesting
  static MyRefreshIndicatorMode? state(BuildContext context) {
    final MyCupertinoSliverRefreshControlState state
    = context.findAncestorStateOfType<MyCupertinoSliverRefreshControlState>()!;
    return state.refreshState;
  }

  static Widget buildSimpleRefreshIndicator(
      BuildContext context,
      MyRefreshIndicatorMode? refreshState,
      double pulledExtent,
      double refreshTriggerPullDistance,
      double refreshIndicatorExtent,
      ) {
    const Curve opacityCurve = Interval(0.4, 0.8, curve: Curves.easeInOut);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: refreshState == MyRefreshIndicatorMode.drag
            ? Opacity(
          opacity: opacityCurve.transform(
              min(pulledExtent / refreshTriggerPullDistance, 1.0)
          ),
          child: const Icon(
            CupertinoIcons.down_arrow,
            color: CupertinoColors.inactiveGray,
            size: 36.0,
          ),
        )
            : Opacity(
          opacity: opacityCurve.transform(
              min(pulledExtent / refreshIndicatorExtent, 1.0)
          ),
          child: const CupertinoActivityIndicator(radius: 14.0),
        ),
      ),
    );
  }

  @override
  MyCupertinoSliverRefreshControlState createState() => MyCupertinoSliverRefreshControlState();
}

class MyCupertinoSliverRefreshControlState extends State<MyCupertinoSliverRefreshControl> {

  static const double _inactiveResetOverscrollFraction = 0.1;

  MyRefreshIndicatorMode? refreshState;

  Future<void>? refreshTask;

  double latestIndicatorBoxExtent = 0.0;
  bool hasSliverLayoutExtent = false;
  bool needRefresh = false;
  bool draging = false;

  @override
  void initState() {
    super.initState();
    refreshState = MyRefreshIndicatorMode.inactive;
  }


  MyRefreshIndicatorMode? transitionNextState() {
    MyRefreshIndicatorMode? nextState;

    void goToDone() {
      nextState = MyRefreshIndicatorMode.done;

      if (SchedulerBinding.instance!.schedulerPhase == SchedulerPhase.idle) {
        setState(() => hasSliverLayoutExtent = false);
      } else {
        SchedulerBinding.instance!.addPostFrameCallback((Duration timestamp) {
          setState(() => hasSliverLayoutExtent = false);
        });
      }
    }

    switch (refreshState) {
      case MyRefreshIndicatorMode.inactive:
        if (latestIndicatorBoxExtent <= 0) {
          return MyRefreshIndicatorMode.inactive;
        } else {
          nextState = MyRefreshIndicatorMode.drag;
        }
        continue drag;
      drag:
      case MyRefreshIndicatorMode.drag:
        if (latestIndicatorBoxExtent == 0) {
          return MyRefreshIndicatorMode.inactive;
        } else if (latestIndicatorBoxExtent < widget.refreshTriggerPullDistance) {
          return MyRefreshIndicatorMode.drag;
        } else {
          ///超过 refreshTriggerPullDistance 就可以进入准备刷新的装备状态
          if (widget.onRefresh != null) {
            HapticFeedback.mediumImpact();
            SchedulerBinding.instance!.addPostFrameCallback((Duration timestamp) {
              needRefresh = true;
              setState(() => hasSliverLayoutExtent = true);
            });
          }
          return MyRefreshIndicatorMode.armed;
        }
      case MyRefreshIndicatorMode.armed:
        if (refreshState == MyRefreshIndicatorMode.armed && !needRefresh) {
          goToDone();
          continue done;
        }
        ///当已经进去装备阶段，拖拽距离没到 refreshIndicatorExtent 的时候
        ///继续返回 armed 状态，知道 latestIndicatorBoxExtent = refreshIndicatorExtent
        ///才进入刷新状态
        if (latestIndicatorBoxExtent > widget.refreshIndicatorExtent) {
          return MyRefreshIndicatorMode.armed;
        } else {
          ///如果这时候手还在拖拽
          if(draging) {
            goToDone();
            continue done;
          }
          nextState = MyRefreshIndicatorMode.refresh;
        }
        continue refresh;
      refresh:
      case MyRefreshIndicatorMode.refresh:
        ///进入刷新状态，先判断是否达到刷新标准
        if (needRefresh) {
          ///还没有触发外部刷新，触发一下
          if (widget.onRefresh != null && refreshTask == null) {
            HapticFeedback.mediumImpact();
            SchedulerBinding.instance!.addPostFrameCallback((Duration timestamp) {
              ///任务完成后清洗状态
              refreshTask = widget.onRefresh!()..whenComplete(() {
                if (mounted) {
                  setState(() {
                    refreshTask = null;
                    needRefresh = false;
                  });
                  refreshState = transitionNextState();
                }
              });
              setState(() => hasSliverLayoutExtent = true);
            });
          }
          return MyRefreshIndicatorMode.refresh;
        } else {
          goToDone();
        }
        continue done;
      done:
      case MyRefreshIndicatorMode.done:
      default:
        ///结束状态
        if (latestIndicatorBoxExtent >
            widget.refreshTriggerPullDistance * _inactiveResetOverscrollFraction) {
          return MyRefreshIndicatorMode.done;
        } else {
          nextState = MyRefreshIndicatorMode.inactive;
        }
        break;
    }

    return nextState;
  }

  ///增加外部判断，处理手是不是还在拖拽，如果还在拖拽不触发刷新
  void notifyScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      if(refreshState == MyRefreshIndicatorMode.armed) {
        /// 放手了
        draging = false;
      }
    } else if (notification is UserScrollNotification) {
      if(notification.direction != ScrollDirection.idle) {
        /// 手还在拖动
        draging = true;
      } else {
        /// 放手了
        draging = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _CupertinoSliverRefresh(
      refreshIndicatorLayoutExtent: widget.refreshIndicatorExtent,
      hasLayoutExtent: hasSliverLayoutExtent,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          latestIndicatorBoxExtent = constraints.maxHeight;
          refreshState = transitionNextState();
          if (latestIndicatorBoxExtent > 0) {
            return widget.builder(
              context,
              refreshState,
              latestIndicatorBoxExtent,
              widget.refreshTriggerPullDistance,
              widget.refreshIndicatorExtent,
            );
          }
          return Container();
        },
      ),
    );
  }
}
