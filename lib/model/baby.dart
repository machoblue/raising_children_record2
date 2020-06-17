
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class Baby {
  String id;
  String name;
  DateTime birthday;
  String photoUrl;
  Sex sex;

  Baby(this.id, this.name, this.birthday, this.photoUrl, this.sex);

  Baby.newInstance(): this(Uuid().v1(), 'Baby', DateTime.now(), defaultBabyIconUrl, Sex.male);

  Baby.fromSnapshot(DocumentSnapshot snapshot): this(
      snapshot['id'].toString(),
      snapshot['name'].toString(),
      DateTime.fromMillisecondsSinceEpoch((snapshot['birthday'] as Timestamp).millisecondsSinceEpoch),
      snapshot['photoUrl'].toString(),
      SexExtension.fromString(snapshot['sex'].toString()),
  );

  Map<String, dynamic> get map {
    return {
      'id': id,
      'name': name,
      'birthday': birthday,
      'photoUrl': photoUrl,
      'sex': sex.string,
    };
  }

  static String get defaultBabyIconUrl => 'https://firebasestorage.googleapis.com/v0/b/raisingchildrenrecord2.appspot.com/o/icon.png?alt=media&token=ce8d2ab5-98bf-42b3-9090-d3dc1459054a';
}

enum Sex {
  male, female, none
}

extension SexExtension on Sex {

  String get string {
    final string = this.toString();
    return string.substring(string.indexOf(".") + 1);
  }

  String get localizedName {
    return Intl.message('$string', name: '${string}');
  }

  static Sex fromString(String string) {
    return Sex.values.firstWhere((value) => value.string == string) ?? Sex.male;
  }
}