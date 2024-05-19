class Food {
  Food({
    required this.id,
    required this.image,
    required this.name,
    required this.price,
    required this.rate,
    required this.cookingTime,
    required this.description,
  });

  String id;
  String image;
  String name;
  String price;
  double rate;
  String cookingTime;
  String description;

  factory Food.fromJson(Map<String, dynamic> json) => Food(
        id: json["id"],
        image: json["image"],
        name: json["name"],
        price: json["price"],
        rate: json["rate"].toDouble(),
        cookingTime: json["cooking_time"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "name": name,
        "price": price,
        "rate": rate,
        "cooking_time": cookingTime,
        "description": description,
      };
}

final dummyFoods = [
  Food(
    id: '1',
    image: 'asset/Tomatoes.jpg',
    name: 'Tomat Segar',
    price: '15.114',
    rate: 4.5,
    cookingTime: '/kg',
    description:
        'Tomat segar, ditanam dengan cermat untuk menciptakan rasa manis yang unik dan kaya nutrisi. Cocok sebagai tambahan dalam salad segar, saus, atau sebagai hiasan menarik dalam hidangan kuliner Anda',
  ),
  Food(
    id: '2',
    image: 'asset/side-view-raw-potatoes-dish.jpg',
    name: 'Kentang Grade A',
    price: '16.680',
    rate: 4.5,
    cookingTime: '/kg',
    description:
        'Kentang berkualitas Grade A, dengan tekstur lembut yang nikmat. Ideal untuk digoreng garing, direbus dalam sup, atau dijadikan puree lembut untuk hidangan yang menggugah selera',
  ),
  Food(
    id: '3',
    image: 'asset/kubis.jpg',
    name: 'Kubis Segar',
    price: '7.072',
    rate: 4,
    cookingTime: '/kg',
    description:
        'Kubis segar dengan warna hijau cerah dan tekstur renyah. Cocok untuk digunakan dalam berbagai masakan, mulai dari sup hingga tumisan. Memberikan rasa segar dan nutrisi yang tinggi.',
  ),
  Food(
    id: '4',
    image: 'asset/Cabai.jpg',
    name: 'Cabai Merah Besar',
    price: '83.817',
    rate: 4.8,
    cookingTime: '/kg',
    description:
        'Cabai merah besar dengan rasa pedas yang khas dan warna merah yang menawan. Ideal untuk memberikan aroma dan rasa pedas pada berbagai hidangan, mulai dari masakan Asia hingga saus barbeque',
  ),
];
