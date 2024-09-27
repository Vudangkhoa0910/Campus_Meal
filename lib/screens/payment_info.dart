import 'dart:core';
import 'dart:core';

import 'package:flutter/material.dart';

class PaymentInfo extends StatefulWidget {
  const PaymentInfo({super.key});

  @override
  State<PaymentInfo> createState() => _PaymentInfoState();
}

class _PaymentInfoState extends State<PaymentInfo> {
  final List<String> dh = ["rice", "fish", "meat", "salad", "egg", "bread"];
  final List<int> count = [2, 3, 4, 2, 4, 5];
  final List<double> fee = [25.3, 24.6, 27.6, 28.9, 30, 10.5];
  double total = 0.0;

  // Phương thức tính tổng
  void calculateTotal() {
    if (count.length != fee.length) {
      throw Exception('Hai danh sách count và fee phải có độ dài bằng nhau.');
    }

    total = 0.0; // Đặt lại giá trị của total trước khi tính lại
    for (int i = 0; i < count.length; i++) {
      total += count[i] * fee[i];
    }
  }

  @override
  Widget build(BuildContext context) {
    calculateTotal();
    return Scaffold(
      appBar: AppBar(
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios_new));
        }),
        title: Text("Thanh toán"),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.865,
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 1.5, color: Color.fromARGB(218, 165, 32, 1)),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
            ),
          ),
          Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  child: Image.asset("assets\qrpay.jpg"),
                ),
              ),
              Spacer(),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                        height: MediaQuery.of(context).size.height * 0.42,
                        width: MediaQuery.of(context).size.width * 2 / 3,
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1.5,
                                color: Color.fromARGB(218, 165, 32, 1)),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: ListView.builder(
                          itemCount: dh.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                height: 80,
                                width:
                                    MediaQuery.of(context).size.width * 2 / 3,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1.5,
                                        color: Color.fromARGB(218, 165, 32, 1)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dh[index],
                                            style: TextStyle(
                                                color: Colors.blue[800],
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Số lượng : ${count[index]}",
                                            style: TextStyle(
                                                color: Colors.blue[800],
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "Giá : ${fee[index]}",
                                            style: TextStyle(
                                                color: Colors.blue[800],
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 2 / 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Tổng : ",
                            style: TextStyle(
                                color: Colors.amber[900],
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        Text("${total}",
                            style: TextStyle(
                                color: Colors.blue[600],
                                fontSize: 20,
                                fontWeight: FontWeight.bold))
                      ],
                    ),
                  )
                ],
              ),
              Spacer(),
              Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.amber[800],
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Center(
                    child: Text(
                  "Lưu hoá đơn",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )),
              ),
              Spacer()
            ],
          ),
        ],
      ),
    );
  }
}
