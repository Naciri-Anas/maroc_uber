class PlacePredictions {
  late String secondary_text;
  late String main_text;
  late String place_id;

  PlacePredictions(
      {required this.secondary_text,
      required this.main_text,
      required this.place_id});

  PlacePredictions.fromJson(Map<String, dynamic> json) {
    place_id = json["place_id"] ?? "";

    if (json["structured_formatting"] != null) {
      main_text = json["structured_formatting"]["main_text"] ?? "";
      secondary_text = json["structured_formatting"]["secondary_text"] ?? "";
    } else {
      main_text = "";
      secondary_text = "";
    }
  }
}
