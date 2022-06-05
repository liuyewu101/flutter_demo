import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/list/refresh_sliver.dart';

import '../pages/home_page.dart';

class pageRefresh3 extends State<HomePage>{

    String currentText = "自定义上下拉刷新样式";
    final int pageSize = 10;
    List<ListItem> items = [];
    bool disposed = false;

    final ScrollController scrollController = ScrollController();
    final GlobalKey<MyCupertinoSliverRefreshControlState> sliverRefreshKey = GlobalKey<MyCupertinoSliverRefreshControlState>();

    @override
    void dispose() {
        disposed = true;
        super.dispose();
    }

    Future<void> onRefresh() async {
        await Future.delayed(const Duration(seconds: 1));
        items.clear();
        for (int i = 0; i < pageSize; i++) {
            ListItem item = ListItem( name: 'refesh+ $i', subName: 'subName+ $i');
            items.add(item);
        }
        if(disposed) {
            return;
        }
        setState(() {});
    }

    Future<void> loadMore() async {
        await Future.delayed(const Duration(seconds: 1));
        for (int i = 0; i < pageSize; i++) {
            ListItem item = ListItem( name: 'loadMore+ $i', subName: 'loadMore+ $i');
            items.add(item);
        }
        if(disposed) {
            return;
        }
        setState(() {});
    }

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();

        ///直接触发下拉
        Future.delayed(const Duration(milliseconds: 500), () {
            scrollController.animateTo(-141,
                duration: const Duration(milliseconds: 600), curve: Curves.linear);
            return true;
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(currentText),
            ),
            body: Container(
                child: NotificationListener(
                    onNotification: (ScrollNotification notification) {
                        ///通知 CupertinoSliverRefreshControl 当前的拖拽状态
                        sliverRefreshKey.currentState!
                            .notifyScrollNotification(notification);
                        ///判断当前滑动位置是不是到达底部，触发加载更多回调
                        if (notification is ScrollEndNotification) {
                            if (scrollController.position.pixels > 0 &&
                                scrollController.position.pixels ==
                                    scrollController.position.maxScrollExtent) {
                                loadMore();
                            }

                        }
                        return false;
                    },
                    child: CustomScrollView(
                        controller: scrollController,

                        ///回弹效果
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        slivers: <Widget>[
                            ///控制显示刷新的 CupertinoSliverRefreshControl
                            MyCupertinoSliverRefreshControl(
                                key: sliverRefreshKey,
                                refreshIndicatorExtent: 100,
                                refreshTriggerPullDistance: 140,
                                onRefresh: onRefresh,
                                builder: buildSimpleRefreshIndicator,
                            ),

                            ///列表区域
                            SliverSafeArea(
                                sliver: SliverList(
                                    ///代理显示
                                    delegate: SliverChildBuilderDelegate(
                                            (BuildContext context, int index) {
                                            if (index == items.length) {
                                                return Container(
                                                    margin: const EdgeInsets.all(10),
                                                    child: const Align(
                                                        child: CircularProgressIndicator(),
                                                    ),
                                                );
                                            }
                                            return Card(
                                                child: Container(
                                                    height: 60,
                                                    alignment: Alignment.centerLeft,
                                                    child: Text("Item ${items[index]} $index"),
                                                ),
                                            );
                                        },
                                        childCount: (items.length >= pageSize)
                                            ? items.length + 1
                                            : items.length,
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}

Widget buildSimpleRefreshIndicator(
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
            child: refreshState != MyRefreshIndicatorMode.refresh
                ? Opacity(
                opacity: opacityCurve.transform(
                    min(pulledExtent / refreshTriggerPullDistance, 1.0)),
                child: const Icon(
                    CupertinoIcons.down_arrow,
                    color: CupertinoColors.inactiveGray,
                    size: 36.0,
                ),
            )
                : Opacity(
                opacity: opacityCurve
                    .transform(min(pulledExtent / refreshIndicatorExtent, 1.0)),
                child: const CupertinoActivityIndicator(radius: 14.0),
            ),
        ),
    );
}

class ListItem  {
    const ListItem({
        required this.name,
        required this.subName,
    });

    final String name;
    final String subName;
}


