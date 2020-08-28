import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:promohunter/models/cart_item_model.dart';
import 'package:promohunter/providers/auth_provider.dart';
import 'package:promohunter/providers/home_provider.dart';
import 'package:promohunter/providers/product_provider.dart';
import 'package:provider/provider.dart';

class ShoppingItemCard extends StatefulWidget {
  final CartItemModel cartItemModel;

  ShoppingItemCard(this.cartItemModel);

  @override
  _ShoppingItemCardState createState() => _ShoppingItemCardState();
}

class _ShoppingItemCardState extends State<ShoppingItemCard> {
  int quantity = 1;
  num total;
  num maxTotal;

  @override
  void initState() {
    super.initState();
    quantity = widget.cartItemModel.quantity;
    total = (widget.cartItemModel.productModel.minPrice) * quantity;
    maxTotal = (widget.cartItemModel.productModel.basicPrice) * quantity;
  }

  void _increase() {
    quantity++;
    updateQuantity();
    total += widget.cartItemModel.productModel.minPrice;
    maxTotal += widget.cartItemModel.productModel.basicPrice;
    context.read<HomeProvider>().changeTotalCartPrice(
        widget.cartItemModel.productModel.basicPrice,
        widget.cartItemModel.productModel.minPrice,
        true);
    if (mounted) setState(() {});
  }

  void _decrease() {
    if (quantity == 1) return;
    quantity--;
    updateQuantity();
    total -= widget.cartItemModel.productModel.minPrice;
    maxTotal -= widget.cartItemModel.productModel.basicPrice;
    context.read<HomeProvider>().changeTotalCartPrice(
        widget.cartItemModel.productModel.basicPrice,
        widget.cartItemModel.productModel.minPrice,
        false);
    if (mounted) setState(() {});
  }

  void updateQuantity() {
    context
        .read<AuthService>()
        .currentUser
        .cartIds
        .firstWhere((element) =>
            element.productModelId == widget.cartItemModel.productModelId)
        .quantity = quantity;
    context
        .read<HomeProvider>()
        .updateUser(context.read<AuthService>().currentUser);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Color(0xFFf9f9f9),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: 8.0, top: 12.0, bottom: 12.0, right: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    overflow: Overflow.visible,
                    children: [
                      Container(
                        height: 132.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                                widget.cartItemModel.productModel.picture),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -8.0,
                        right: -8.0,
                        child: GestureDetector(
                          onTap: () async {
                            await context.read<ProductProvider>().remFromCart();
                            context.read<HomeProvider>().remFromCart(
                                widget.cartItemModel.productModelId);
                            context
                                .read<HomeProvider>()
                                .filteredCart
                                .remove(widget.cartItemModel.productModel);
                            context.read<HomeProvider>().refresh();
                          },
                          child: Container(
                            padding: EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).accentColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.clear,
                              size: 24.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${widget.cartItemModel.productModel.name}',
                              style: TextStyle(
                                color: Color(0xFF808080),
                                fontFamily: 'sans-serif',
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Text(
                            'Rs. ${total.toStringAsFixed(2)} / ',
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontFamily: 'sans-serif',
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${maxTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Color(0xFF808080),
                              fontFamily: 'sans-serif',
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.0),
                      Row(
                        children: [
                          Spacer(),
                          IconButton(
                            icon: Icon(
                              Icons.remove,
                              size: 48.0,
                              color: Color(0xFFff0000),
                            ),
                            onPressed: () => _decrease(),
                          ),
                          Spacer(flex: 2),
                          Text(
                            '$quantity',
                            style: TextStyle(
                              color: Color(0xFF808080),
                              fontFamily: 'sans-serif',
                              fontSize: 32.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(flex: 2),
                          IconButton(
                            icon: Icon(
                              Icons.add,
                              size: 48.0,
                              color: Theme.of(context).accentColor,
                            ),
                            onPressed: () => _increase(),
                          ),
                          Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Theme.of(context).accentColor,
            thickness: 1.5,
          ),
        ],
      ),
    );
  }
}
