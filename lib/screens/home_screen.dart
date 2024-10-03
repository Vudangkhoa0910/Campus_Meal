import 'package:campus_catalogue/models/buyer_model.dart';
import 'package:campus_catalogue/screens/cart.dart';
import 'package:campus_catalogue/screens/history_user_page.dart';
import 'package:campus_catalogue/screens/ntf_user_page.dart';
import 'package:campus_catalogue/screens/profile_use_page.dart';
import 'package:campus_catalogue/screens/search_screen.dart';
import 'package:campus_catalogue/screens/search_screen.dart';
import 'package:campus_catalogue/screens/search_screen.dart';
import 'package:campus_catalogue/screens/shop_info.dart';
import 'package:campus_catalogue/screens/userType_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_catalogue/constants/colors.dart';
import 'package:campus_catalogue/constants/typography.dart';

class ShopHeader extends StatelessWidget {
  final String name;
  const ShopHeader({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 10, 0),
        child: Text(name,
            style: AppTypography.textMd.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: AppColors.secondary)),
      ),
    );
  }
}

class ShopCardWrapper extends StatelessWidget {
  final Buyer buyer;
  final List shops; // Map {name, imgURL, rating, location}

  const ShopCardWrapper({
    super.key,
    required this.shops,
    required this.buyer,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
          itemCount: shops.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShopPage(
                                name: shops[index]["shop_name"],
                                rating: "0",
                                location: shops[index]["location"],
                                menu: shops[index]["menu"],
                                ownerName: shops[index]["owner_name"],
                                upiID: shops[index]["upi_id"],
                                buyer: buyer,
                              ))),
                  child: ShopCard(
                      name: shops[index]["shop_name"],
                      rating: "0",
                      location: shops[index]["location"],
                      menu: shops[index]["menu"],
                      ownerName: shops[index]["owner_name"],
                      upiID: shops[index]["upi_id"],
                      status: true,
                      imageUrl: shops[index]["img"]),
                ));
          }),
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
  final bool status;
  final String imageUrl; // Thêm trường imageUrl

  const ShopCard(
      {super.key,
      required this.name,
      required this.rating,
      required this.location,
      required this.menu,
      required this.ownerName,
      required this.upiID,
      required this.status,
      required this.imageUrl}); // Thêm imageUrl trong constructor

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 125,
      width: MediaQuery.of(context).size.width * 0.5,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: const Color(0xFFFFF2E0),
        child: Stack(
          children: [
            // Sử dụng CachedNetworkImage để hiển thị ảnh từ Firebase
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/iconshop.jpg', // Đường dẫn đến hình ảnh thay thế
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5), // Đặt overlay mờ
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        name,
                        style: AppTypography.textMd.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      Text(
                        location,
                        style: AppTypography.textSm.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: const Color(0xFFFFFEF6),
                    ),
                    child: Row(
                      children: [
                        Text(
                          rating,
                          style: AppTypography.textSm.copyWith(
                              fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                        const Icon(
                          Icons.star,
                          size: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationCardWrapper extends StatefulWidget {
  const LocationCardWrapper({super.key});

  @override
  State<LocationCardWrapper> createState() => _LocationCardWrapperState();
}

class _LocationCardWrapperState extends State<LocationCardWrapper> {
  void getShopsFromLocation(shopLocation, context) async {
    List shopSearchResults = [];
    final searchResult = await FirebaseFirestore.instance
        .collection("shop")
        .where("location", isEqualTo: shopLocation)
        .get();
    for (var doc in searchResult.docs) {
      shopSearchResults.add(doc.data());
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SearchScreen(
                  shopResults: shopSearchResults,
                  isSearch: true,
                  title: "Explore IITG",
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(20, 35, 10, 0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text("What are you looking for?",
                    style: AppTypography.textMd.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: AppColors.secondary)),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Wrap(spacing: 8.8, runSpacing: 6.5, children: [
                  GestureDetector(
                    onTap: () =>
                        getShopsFromLocation("Hostel Canteen", context),
                    child: const LocationCard(
                        name: "Hostel Canteens",
                        imgURL: "assets/hostel_canteens.png"),
                  ),
                  GestureDetector(
                    onTap: () =>
                        getShopsFromLocation("Hostel Juice Centre", context),
                    child: const LocationCard(
                        name: "Hostel Juice Centres",
                        imgURL: "assets/core_canteens.png"),
                  ),
                  GestureDetector(
                    onTap: () =>
                        getShopsFromLocation("Market Complex", context),
                    child: const LocationCard(
                        name: "Market Complex",
                        imgURL: "assets/market_complex.png"),
                  ),
                  GestureDetector(
                    onTap: () => getShopsFromLocation("Khokha Market", context),
                    child: const LocationCard(
                        name: "Khokha Market",
                        imgURL: "assets/khokha_stalls.png"),
                  ),
                  GestureDetector(
                    onTap: () => getShopsFromLocation("Food Court", context),
                    child: const LocationCard(
                        name: "Food Court", imgURL: "assets/food_court.png"),
                  ),
                  GestureDetector(
                    onTap: () =>
                        getShopsFromLocation("Swimming Pool Area", context),
                    child: const LocationCard(
                        name: "Swimming Pool Area",
                        imgURL: "assets/food_van.png"),
                  ),
                ]),
              ),
            ],
          ),
        ));
  }
}

class LocationCard extends StatelessWidget {
  final String name;
  final String imgURL;
  const LocationCard({super.key, required this.name, required this.imgURL});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      width: MediaQuery.of(context).size.width * 0.285,
      child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: const Color(0xFFFFF2E0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(imgURL),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                  child: Text(
                    name,
                    style: AppTypography.textMd.copyWith(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          )),
    );
  }
}

class SearchInput extends StatefulWidget {
  const SearchInput({super.key});
  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  final searchController = TextEditingController();
  List<String> searchTerms = [];
  List shopSearchResult = [];

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    searchController.dispose();
    super.dispose();
  }

  getSearchResult(searchTerm) async {
    final searchResult = await FirebaseFirestore.instance
        .collection("cache")
        .doc(searchTerm)
        .get();
    return searchResult;
  }

  void searchSubmit(context) async {
    searchTerms = searchController.text.split(' ');
    Set shops = {};
    for (int i = 0; i < searchTerms.length; i++) {
      var tmp = (await getSearchResult(searchTerms[i]));
      shopSearchResult = tmp['list'];

      for (var shop in shopSearchResult) {
        final tmp =
            await FirebaseFirestore.instance.collection("shop").doc(shop).get();
        shops.add(tmp.data());
      }
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SearchScreen(
                    shopResults: shops.toList(),
                    isSearch: true,
                    title: "Explore IITG",
                  )));
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
                              width: 1, color: AppColors.backgroundOrange)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              width: 1, color: AppColors.backgroundOrange)),
                      hintText: 'Search',
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 18),
                      suffixIcon: const Icon(
                        Icons.search,
                        color: AppColors.secondary,
                        size: 30,
                      )),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  Buyer buyer;
  HomeScreen({Key? key, required this.buyer}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<String> _titles = [
    "Explore IITG",
    "Cart",
    "History",
    "Notifications",
    "Profile",
  ];

  Future<List> getCampusFavouriteShops() async {
    List tmp = [];
    final shops = await FirebaseFirestore.instance
        .collection("shop")
        .orderBy("rating", descending: true)
        .limit(10)
        .get();
    for (var doc in shops.docs) {
      tmp.add(doc);
    }
    return tmp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            // Navigate back to the UserTypeSelectionScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserType()),
            );
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.backgroundOrange,
          ),
        ),
        backgroundColor: AppColors.backgroundYellow,
        elevation: 0,
        centerTitle: true,
        title: Text(_titles[_selectedIndex],
            style: AppTypography.textMd.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.backgroundOrange)),
      ),
      backgroundColor: AppColors.backgroundYellow,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SearchInput(),
                const LocationCardWrapper(),
                const ShopHeader(name: "Campus Favourites"),
                FutureBuilder<List<dynamic>>(
                  future: getCampusFavouriteShops(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<dynamic>> snapshot) {
                    if (snapshot.hasData) {
                      final campusFavs = snapshot.data!;
                      return ShopCardWrapper(
                        shops: campusFavs,
                        buyer: widget.buyer,
                      );
                    } else {
                      return const CircularProgressIndicator(
                          color: AppColors.backgroundOrange);
                    }
                  },
                ),
                const ShopHeader(name: "Recommended"),
                FutureBuilder<List<dynamic>>(
                  future: getCampusFavouriteShops(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<dynamic>> snapshot) {
                    if (snapshot.hasData) {
                      final campusFavs = snapshot.data!;
                      return ShopCardWrapper(
                        shops: campusFavs,
                        buyer: widget.buyer,
                      );
                    } else {
                      return const CircularProgressIndicator(
                          color: AppColors.backgroundOrange);
                    }
                  },
                ),
              ],
            ),
          ),
          Cart(
            buyer: widget.buyer,
          ),
          HistoryPageUser(
            buyer: widget.buyer,
          ),
          NtfUserPage(),
          ProfileUsePage(
            buyer: widget.buyer,
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        // selectedItemColor: AppColors.backgroundOrange,
        type: BottomNavigationBarType.fixed, // Đảm bảo loại là fixed
        backgroundColor: Colors.white, // Tuỳ chọn: Đặt màu nền mong muốn
        selectedItemColor: AppColors.backgroundOrange, // Màu của mục được chọn
        unselectedItemColor: Colors.grey, // Màu của các mục không được chọn
        // selectedLabelStyle: AppTypography.textMd.copyWith(
        //   fontWeight: FontWeight.w700, // Tuỳ chọn: Kiểu chữ của nhãn được chọn
        // ),
        // unselectedLabelStyle: AppTypography.textMd.copyWith(
        //   fontWeight: FontWeight.w400,
        // ), // Tuỳ chọn: Kiểu chữ của nhãn không được chọn
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
