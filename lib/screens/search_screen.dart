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
    searchController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> getSearchResult(String searchTerm) async {
    final searchResult = await FirebaseFirestore.instance
        .collection("cache")
        .doc(searchTerm)
        .get();

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
                      borderSide: const BorderSide(width: 1, color: AppColors.backgroundOrange),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(width: 1, color: AppColors.backgroundOrange),
                    ),
                    hintText: 'Search',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 18),
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

class ShopCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShopPage(
              name: name,
              rating: "0",
              location: location,
              menu: menu,
              ownerName: ownerName,
              upiID: upiID,
              buyer: buyer,
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
                      name,
                      style: AppTypography.textMd
                          .copyWith(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.pin_drop, size: 18),
                        Text(location,
                            style: AppTypography.textSm.copyWith(
                                fontSize: 12, fontWeight: FontWeight.w400)),
                      ],
                    ),
                    Container(
                      width: 40,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: const Color(0xFFFFFEF6),
                      ),
                      child: Row(
                        children: [
                          Text(
                            rating,
                            style: AppTypography.textSm.copyWith(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const Icon(Icons.star, size: 15)
                        ],
                      ),
                    )
                  ],
                ),
                Image.asset("assets/temp.png"),
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
  @override
  Widget build(BuildContext context) {
    List openShopsAndFoods = widget.shopResults;
    List closedShops = [];

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
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.backgroundOrange,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}
