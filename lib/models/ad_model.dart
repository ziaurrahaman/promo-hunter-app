class AdModel {
  String id;
  String image;

  AdModel.fromMap(this.id, Map m) : this.image = m['image'];
}
