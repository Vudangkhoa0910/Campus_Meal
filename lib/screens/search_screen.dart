import 'package:campus_catalogue/models/buyer_model.dart';
import 'package:campus_catalogue/screens/shop_info.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_catalogue/constants/colors.dart';
import 'package:campus_catalogue/constants/typography.dart';

class SearchInput extends StatefulWidget {
  final Buyer buyer;
  const SearchInput({super.key, required this.buyer});

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  final searchController = TextEditingController();
  List<String> searchTerms = [];
  List<dynamic> shopSearchResult = [];

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    searchController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> getSearchResult(String searchTerm) async {
    final searchResult = await FirebaseFirestore.instance
        .collection("cache")
        .doc(searchTerm)
        .get();

    // Kiểm tra tài liệu có tồn tại không
    if (searchResult.exists) {
      return searchResult['list'] ?? [];
    } else {
      return [];
    }
  }

  void searchSubmit(BuildContext context) async {
    searchTerms = searchController.text.split(' ');
    Set<dynamic> shops = {};

    for (String term in searchTerms) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("shop")
          .where("shop_name", isGreaterThanOrEqualTo: term)
          .where("shop_name", isLessThanOrEqualTo: term + '\uf8ff')
          .get();

      for (var shopDoc in querySnapshot.docs) {
        shops.add(shopDoc.data());
      }
    }

    if (shops.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchScreen(
            shopResults: shops.toList(),
            isSearch: true,
            title: "Explore IITG",
            buyer: widget.buyer,
          ),
        ),
      );
    } else {
      // Hiển thị thông báo nếu không tìm thấy kết quả nào
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tìm thấy kết quả nào.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 15, 25, 0),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                flex: 1,
                child: TextField(
                  controller: searchController,
                  onSubmitted: (e) => searchSubmit(context),
                  autofocus: false,
                  cursorColor: Colors.grey,
                  decoration: InputDecoration(
                    isDense: true,
                    fillColor: Colors.white,
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          width: 1, color: AppColors.backgroundOrange),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          width: 1, color: AppColors.backgroundOrange),
                    ),
                    hintText: 'Search',
                    hintStyle:
                        const TextStyle(color: Colors.grey, fontSize: 18),
                    suffixIcon: const Icon(
                      Icons.search,
                      color: AppColors.secondary,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ShopCard extends StatefulWidget {
  final String name;
  final String rating;
  final String location;
  final List menu;
  final String ownerName;
  final String upiID;
  final Buyer buyer;

  const ShopCard({
    super.key,
    required this.name,
    required this.rating,
    required this.location,
    required this.menu,
    required this.ownerName,
    required this.upiID,
    required this.buyer,
  });

  @override
  State<ShopCard> createState() => _ShopCardState();
}

class _ShopCardState extends State<ShopCard> {
  Future<double> getRating(String shopName) async {
    double totalRating = 0;
    int index = 0;
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection('orders')
        .where('shop_name', isEqualTo: shopName)
        .get();
    if (snap.docs.isNotEmpty) {
      for (var doc in snap.docs) {
        var ratingData = doc['rating'];
        double rating = (ratingData is num) ? ratingData.toDouble() : 0;
        if (rating > 0) {
          totalRating += rating;
          index++;
        }
      }
    }
    return index > 0 ? totalRating / index : 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShopPage(
              name: widget.name,
              rating: "0",
              location: widget.location,
              menu: widget.menu,
              ownerName: widget.ownerName,
              upiID: widget.upiID,
              buyer: widget.buyer,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: const Color(0xFFFFF2E0),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: AppTypography.textMd
                          .copyWith(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.pin_drop, size: 18),
                        Text(widget.location,
                            style: AppTypography.textSm.copyWith(
                                fontSize: 12, fontWeight: FontWeight.w400)),
                      ],
                    ),
                    FutureBuilder<double>(
                      future: getRating(widget.name),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            "Loading...",
                            style: AppTypography.textSm.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            "Error",
                            style: AppTypography.textSm.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        } else {
                          double rating = snapshot.data ?? 0;
                          int fullStars = rating.floor();
                          bool hasHalfStar = (rating - fullStars) >= 0.5;

                          return Row(
                            children: [
                              // Display full stars
                              for (int i = 0; i < fullStars; i++)
                                const Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Colors.yellow,
                                ),
                              // Display half star if needed
                              if (hasHalfStar)
                                const Icon(
                                  Icons.star_half,
                                  size: 12,
                                  color: Colors.yellow,
                                ),
                              // Display empty stars
                              for (int i = 0;
                                  i < (5 - fullStars - (hasHalfStar ? 1 : 0));
                                  i++)
                                const Icon(
                                  Icons.star_border,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: AppTypography.textSm.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFFA500),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(8.0), // Đặt bán kính bo cạnh
                  child: Image.asset(
                    "assets/iconshop.jpg",
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  final List shopResults;
  final bool isSearch;
  final String title;
  final Buyer buyer;

  const SearchScreen({
    super.key,
    required this.shopResults,
    required this.isSearch,
    required this.title,
    required this.buyer,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class ShopHeader extends StatelessWidget {
  final String name;
  final Buyer buyer;

  const ShopHeader({super.key, required this.name, required this.buyer});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Text(
          name,
          style: AppTypography.textMd.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary),
        ),
      ),
    );
  }
}

class _SearchScreenState extends State<SearchScreen> {
  String currentLocation = '';
  @override
  Widget build(BuildContext context) {
    List openShopsAndFoods = widget.shopResults;
    List closedShops = [];

    if (openShopsAndFoods.isNotEmpty) {
      currentLocation = openShopsAndFoods[0]["location"] ?? 'Unknown Location';
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.backgroundOrange,
          ),
        ),
        backgroundColor: AppColors.backgroundYellow,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: AppTypography.textMd.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.backgroundOrange),
        ),
      ),
      backgroundColor: AppColors.backgroundYellow,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SearchInput(buyer: widget.buyer),
            ShopHeader(name: "Currently open shops/foods", buyer: widget.buyer),
            for (var shopOrFood in openShopsAndFoods)
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShopPage(
                      name: shopOrFood["shop_name"] ?? 'Unknown Shop',
                      rating: "0",
                      location: shopOrFood["location"] ?? 'Unknown Location',
                      menu: shopOrFood["menu"] ?? [],
                      ownerName: shopOrFood["owner_name"] ?? 'Unknown Owner',
                      upiID: shopOrFood["upi_id"] ?? 'Unknown UPI',
                      buyer: widget.buyer,
                    ),
                  ),
                ),
                child: ShopCard(
                  name: shopOrFood["shop_name"] ?? 'Unknown Shop',
                  rating: "0",
                  location: shopOrFood["location"] ?? 'Unknown Location',
                  menu: shopOrFood["menu"] ?? [],
                  ownerName: shopOrFood["owner_name"] ?? 'Unknown Owner',
                  upiID: shopOrFood["upi_id"] ?? 'Unknown UPI',
                  buyer: widget.buyer,
                ),
              ),
            ShopHeader(name: "Currently closed shops", buyer: widget.buyer),
            for (var shop in closedShops)
              ShopCard(
                name: shop["shop_name"],
                rating: "0",
                location: shop["location"],
                menu: shop["menu"],
                ownerName: shop["owner_name"],
                upiID: shop["upi_id"],
                buyer: widget.buyer,
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.backgroundYellow,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Nút Home
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'Home',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20), // Khoảng cách giữa Home và Shop
              // Nút Shop với biểu tượng Location
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Container(
                        width: 250,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.info,
                                color: Colors.white), // Biểu tượng thông báo
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Please choose in $currentLocation.',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundOrange,
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on,
                            color: Colors.white), // Biểu tượng Location
                        SizedBox(width: 8),
                        Text(
                          'Shop in $currentLocation',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
