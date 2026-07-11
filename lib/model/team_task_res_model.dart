class TeamTaskResModel {
  dynamic id;
  dynamic title;
  dynamic description;
  dynamic status;
  dynamic dueDate;
  dynamic priority;

  TeamTaskResModel(
      {this.id,
        this.title,
        this.status,
        this.description,
        this.dueDate,
        this.priority,});

  TeamTaskResModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    status = json['price']; ///price as status
    description = json['description'];
    dueDate = json['category']; ///category as dueDate
    priority = json['image'];///image as priority
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['price'] = this.status;
    data['description'] = this.description;
    data['category'] = this.dueDate;
    data['image'] = this.priority;
    return data;
  }
}

