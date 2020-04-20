
class User {
  String id;
  String name;
  String photoUrl;

  User(this.id, this.name, this.photoUrl);

  User.fromMap(Map map): this(
      map['id'],
      map['name'],
      map['photoUrl']
  );
}