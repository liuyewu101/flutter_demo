import 'dart:core';

import 'dart:convert';
import 'dart:io';

Future<Data> httpClientData(int page,int size) async {
  final request = await HttpClient().getUrl(Uri.parse("https://api.apiopen.top/api/getHaoKanVideo?page=$page&size=$size"));
  final response = await request.close();
  if (response.statusCode == HttpStatus.ok) {
    var json = await response.transform(utf8.decoder).join();
    return Data.fromJson(jsonDecode(json));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Data');
  }
}

class Data {
  final int code;
  final String message;
  final Result result;

  const Data({
    required this.code,
    required this.message,
    required this.result,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      code: json['code'],
      message: json['message'],
      result: Result.fromJson(json['result']),
    );
  }
}

class Result {
  final int total;
  final List<ItemBean> list;

  const Result({
    required this.total,
    required this.list,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    var listT = json['list'] as List;
    List<ItemBean> lists = listT.map((i) => ItemBean.fromJson(i)).toList();
    return Result(
      total: json['total'],
      list: lists,
    );
  }

}

class ItemBean {
  final int id;
  final String title;
  final String userName;
  final String userPic;
  final String coverUrl;
  final String playUrl;
  final String duration;

  const ItemBean({
    required this.id,
    required this.title,
    required this.userName,
    required this.userPic,
    required this.coverUrl,
    required this.playUrl,
    required this.duration,
  });

  factory ItemBean.fromJson(Map<String, dynamic> json) {
    return ItemBean(
      id: json['id'],
      title: json['title'],
      userName: json['userName'],
      userPic: json['userPic'],
      coverUrl: json['coverUrl'],
      playUrl: json['playUrl'],
      duration: json['duration'],
    );
  }
}

// {
//   "code": 200,
//   "message": "成功!",
//   "result": {
//     "total": 11860,
//     "list": [
//       {
//       "id": 7525,
//       "title": "敢直接叫向华强要人，周润发当配角，给张学友做个表情包",
//       "userName": "也毁灭另一些人",
//       "userPic": "https://pic.rmb.bdstatic.com/bjh/user/00f938d6a2615985a2fe68b40252d319.jpeg?x-bce-process=image/resize,m_lfit,w_200,h_200&autime=33634",
//       "coverUrl": "https://f7.baidu.com/it/u=4107050099,3096145322&fm=222&app=108&f=JPEG@s_2,w_681,h_381,q_100",
//       "playUrl": "http://vd2.bdstatic.com/mda-nc5e6rphet3kr6td/cae_h264_delogo/1646561464607182321/mda-nc5e6rphet3kr6td.mp4",
//       "duration": "01:19"
//       },
//       {
//       "id": 10948,
//       "title": "吕秀才倒霉的一天",
//       "userName": "影视小滔",
//       "userPic": "https://pic.rmb.bdstatic.com/bjh/user/ae482e23dfca594081b51d558d8367ac.jpeg?x-bce-process=image/resize,m_lfit,w_200,h_200&autime=37424",
//       "coverUrl": "https://f7.baidu.com/it/u=3822864426,1054969009&fm=222&app=108&f=JPEG@s_2,w_681,h_381,q_100",
//       "playUrl": "http://vd3.bdstatic.com/mda-ndg2vcdujbewdd9m/cae_h264_delogo/1650161723467982957/mda-ndg2vcdujbewdd9m.mp4",
//       "duration": "05:21"
//       }
//     ]
//   }
// }