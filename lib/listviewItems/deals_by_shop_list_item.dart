import 'package:flutter/material.dart';
import 'package:promohunter/providers/auth_provider.dart';
import 'package:promohunter/providers/home_provider.dart';
import 'package:promohunter/ui/library_screen.dart';
// import 'package:huneter_card_app_home/model/deals_by_shop_model.dart';

class DealsByShopItem extends StatelessWidget {
  final String shopName;
  final int index;

  DealsByShopItem({this.shopName, this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<HomeProvider>(context, listen: false)
            .filterPromoShopProducts(shopName);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => LibraryScreen(
                  index: 0,
                  sName: shopName,
                )));
        // final deals =
        //     context.read<HomeProvider>().filteredShops;
        // for (int i = 0; i < deals.length; i++) {
        //   print(deals[i]);
        // }
      },
      child: Container(
        margin: EdgeInsets.only(left: 4, right: 4),
        height: 40,
        width: 120,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: index.isEven ? Color(0xff000c4f) : Colors.amber),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              shopName,
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
