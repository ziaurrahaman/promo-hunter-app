import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:promohunter/providers/auth_provider.dart';
import 'package:promohunter/providers/product_provider.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = context.select((ProductProvider p) => p.product);
    final brand = context.select((ProductProvider p) => p.brand);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Stack(
        children: [
          Container(
            height: 180.0,
            width: 180.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                image: CachedNetworkImageProvider(product.picture),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            right: 0.0,
            left: 0.0,
            child: Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color(0xFFf9ba00),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${brand?.name}',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'sans-serif',
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${product.name}',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'sans-serif',
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Rs. ${product.minPrice}',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'sans-serif',
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (product.minPrice != product.basicPrice) ...[
                        Text(
                          ' / ',
                          style: TextStyle(
                            color: Color(0xFF000c4f),
                            fontFamily: 'sans-serif',
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${product.basicPrice}',
                          style: TextStyle(
                            color: Color(0xFF000c4f),
                            fontFamily: 'sans-serif',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
