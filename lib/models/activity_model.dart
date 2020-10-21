import 'package:camp/models/user_account.dart';

import 'details_model.dart';

class Activity {
  Activity({
    this.data,
    this.meta,
  });

  List<Datum> data;
  Meta meta;
  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        meta: Meta.fromJson(json["meta"]),
      );

  // Map<String, dynamic> toJson() => {
  //       "data": List<dynamic>.from(data.map((x) => x.toJson())),
  //       "meta": meta.toJson(),
  //     };
}

class Datum {
  Datum({
    this.description,
    this.lapse,
    this.user,
    this.type,
    this.details,
  });

  String description;
  String lapse;
  UserAccount user;
  String type;
  Details details;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        description: json["description"],
        lapse: json["lapse"],
        user: UserAccount.fromJson(json["user"]),
        type: json["type"],
        details: Details.fromJson(json["details"]),
      );

  // Map<String, dynamic> toJson() => {
  //       "description": description,
  //       "lapse": lapse,
  //       "user": user.toJson(),
  //       "type": type,
  //       "details": details.toJson(),
  //     };
}

class Meta {
  Meta({
    this.pagination,
  });

  Pagination pagination;

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        pagination: Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "pagination": pagination.toJson(),
      };
}

class Pagination {
  Pagination({
    this.total,
    this.count,
    this.perPage,
    this.currentPage,
    this.totalPages,
    this.links,
  });

  int total;
  int count;
  int perPage;
  int currentPage;
  int totalPages;
  Links links;

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        total: json["total"],
        count: json["count"],
        perPage: json["per_page"],
        currentPage: json["current_page"],
        totalPages: json["total_pages"],
        links: Links.fromJson(json["links"]),
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "count": count,
        "per_page": perPage,
        "current_page": currentPage,
        "total_pages": totalPages,
        "links": links.toJson(),
      };
}

class Links {
  Links({
    this.previous,
    this.next,
  });

  String previous;
  String next;

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        previous: json["previous"],
        next: json["next"],
      );

  Map<String, dynamic> toJson() => {
        "previous": previous,
        "next": next,
      };
}
