import 'package:flutter/material.dart';
import '../pages/home_page.dart';

// ignore: camel_case_types
class pageRefresh1 extends State<HomePage>{

    String currentText = "普通上下拉刷新1";
    final int pageSize = 10;
    List<ListItem> items = [];
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
    void initState() {
        super.initState();
        scrollController.addListener(() {
            ///判断当前滑动位置是不是到达底部，触发加载更多回调
            if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
                loadMore();
            }
        });
        Future.delayed(const Duration(seconds: 0), (){
            refreshKey.currentState!.show();
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(currentText),
            ),
            body: Container(
                child: RefreshIndicator(
                    ///GlobalKey，用户外部获取RefreshIndicator的State，做显示刷新
                    key: refreshKey,

                    ///下拉刷新触发，返回的是一个Future
                    onRefresh: onRefresh,
                    child: ListView.builder(
                        ///保持ListView任何情况都能滚动，解决在RefreshIndicator的兼容问题。
                        physics: const AlwaysScrollableScrollPhysics(),

                        ///根据状态返回
                        itemBuilder: (context, index) {
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

                        ///根据状态返回数量
                        itemCount: (items.length >= pageSize)
                            ? items.length + 1
                            : items.length,

                        ///滑动监听
                        controller: scrollController,
                    ),
                ),
            ),
        );
    }
}

class ListItem  {
    const ListItem({
        required this.name,
        required this.subName,
    });

    final String name;
    final String subName;
}


