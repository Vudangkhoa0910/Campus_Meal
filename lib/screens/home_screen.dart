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
  final List shops; // Map {name, imgURL, rating, location}
  const ShopCardWrapper({super.key, required this.shops});

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
                            ))),
                child: ShopCard(
                    name: shops[index]["shop_name"],
                    rating: "0",
                    location: shops[index]["location"],
                    menu: shops[index]["menu"],
                    ownerName: shops[index]["owner_name"],
                    upiID: shops[index]["upi_id"],
                    status: true),
              ),
            );
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
  const ShopCard(
      {super.key,
      required this.name,
      required this.rating,
      required this.location,
      required this.menu,
      required this.ownerName,
      required this.upiID,
      required this.status});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 125,
      width: MediaQuery.of(context).size.width * 0.5,
      child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: const Color(0xFFFFF2E0),
          child: Container(
            padding: const EdgeInsets.all(10),
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
                      style: AppTypography.textMd
                          .copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    Text(location,
                        style: AppTypography.textSm.copyWith(
                            fontSize: 10, fontWeight: FontWeight.w400))
                  ],
                ),
                Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: const Color(0xFFFFFEF6)),
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
                        )
                      ],
                    ))
              ],
            ),
          )),
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
      height: 110,
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

