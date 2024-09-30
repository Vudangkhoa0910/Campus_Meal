import 'package:campus_catalogue/constants/colors.dart';
import 'package:campus_catalogue/constants/typography.dart';
import 'package:campus_catalogue/models/item_model.dart';
import 'package:campus_catalogue/services/database_service.dart';
import 'package:campus_catalogue/models/shopModel.dart';
import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String name;
  final num price;
  final String description;
  final bool vegetarian;
  final String img;
  const ItemCard(
      {super.key,
      required this.name,
      required this.price,
      required this.description,
      required this.vegetarian,
      required this.img});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
      child: Container(
          decoration: BoxDecoration(
              color: const Color(0xFFFFF2E0),
              borderRadius: BorderRadius.circular(10)),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  // Sửa để tránh lỗi overflow
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // if (vegetarian)
                      //   Text(
                      //     "VEG",
                      //     style: AppTypography.textSm.copyWith(
                      //         color: Color.fromARGB(255, 0, 196, 0),
                      //         fontSize: 14),
                      //   )
                      // else
                      // Text("NON VEG",
                      //     style: AppTypography.textSm.copyWith(
                      //         color: Color.fromARGB(255, 197, 0, 0),
                      //         fontSize: 14)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                        child: Text("PRICE: $price",
                            style: AppTypography.textSm.copyWith(fontSize: 14)),
                      ),
                      Text(
                        name,
                        style: AppTypography.textMd.copyWith(
                            fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        description,
                        style: AppTypography.textSm.copyWith(
                            fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 200,
                          height: 30,
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(238, 118, 0, 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Center(
                            child: Text(
                              "ADD ",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.backgroundOrange, width: 1.5),
                      borderRadius: BorderRadius.circular(20)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      img,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class ShopPage extends StatefulWidget {
  final ShopModel? shop;
  final String name;
  final String rating;
  final String location;
  final List menu;
  final String ownerName;
  final String upiID;
  const ShopPage({
    super.key,
    this.shop,
    required this.name,
    required this.rating,
    required this.location,
    required this.menu,
    required this.ownerName,
    required this.upiID,
  });

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  @override
  Widget build(BuildContext context) {
    print(widget.menu);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundYellow,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.backgroundOrange,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        centerTitle: true,
        title: Text(widget.name,
            style: AppTypography.textMd.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.backgroundOrange)),
      ),
      backgroundColor: AppColors.backgroundYellow,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(20),
              height: 120,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.pin_drop_rounded,
                            size: 15,
                          ),
                          Text(widget.location,
                              style: AppTypography.textMd.copyWith(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.timelapse_rounded, size: 15),
                          Text("9 AM TO 10 PM",
                              style: AppTypography.textMd.copyWith(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.shopping_cart, size: 15),
                          Text("${widget.menu.length} ITEMS AVAILABLE",
                              style: AppTypography.textMd.copyWith(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Container(
                          width: 30,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: AppColors.signIn),
                          child: Row(
                            children: [
                              Text(
                                widget
                                    .rating, // Thay giá trị cố định bằng rating từ widget
                                style: AppTypography.textSm.copyWith(
                                    fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              const Icon(
                                Icons.star,
                                size: 15,
                              )
                            ],
                          ))
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "All Items",
                style: AppTypography.textMd
                    .copyWith(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            for (var item in widget.menu)
              ItemCard(
                name: item["name"] ?? 'Unknown',
                price: item["price"] ?? 0.0,
                description: item["description"] ?? 'No description',
                vegetarian: item["veg"] ?? false,
                img: item["img"],
              ),
          ],
        ),
      ),
    );
  }
}
