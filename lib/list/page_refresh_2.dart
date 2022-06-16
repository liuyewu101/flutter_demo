import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../data/custom_data_dio.dart';
import '../pages/home_page.dart';

// ignore: camel_case_types
class pageRefresh2 extends State<HomePage>{

    String currentText = "普通上下拉刷新2";
    final int pageSize = 10;
    int page = 0;
    List<ItemBean> items = [];
    bool disposed = false;

    final ScrollController scrollController = ScrollController();
    final GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey();

    @override
    void dispose() {
        disposed = true;
        super.dispose();
    }

    Future<void> onRefresh() async {
        await Future.delayed(const Duration(seconds: 1));
        items.clear();

        Data data = await dioPostData(page = 0, pageSize);
        items.addAll(data.result.list);

        if(disposed) {
            return;
        }
        setState(() {});
    }

    Future<void> loadMore() async {
        await Future.delayed(const Duration(seconds: 1));
        page++;
        Data data = await dioData(page , pageSize);
        items.addAll(data.result.list);
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
                                CupertinoSliverRefreshControl(
                                    refreshIndicatorExtent: 100,
                                    refreshTriggerPullDistance: 140,
                                    onRefresh: onRefresh,
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
                                )
                        ],
                    ),
                ),
            ),
        );
    }
}


