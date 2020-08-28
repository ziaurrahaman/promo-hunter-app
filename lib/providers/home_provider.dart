import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:promohunter/models/achievements_points_model.dart';
import 'package:promohunter/models/ad_model.dart';
import 'package:promohunter/models/brand_model.dart';
import 'package:promohunter/models/brochures_model.dart';
import 'package:promohunter/models/cart_item_model.dart';
import 'package:promohunter/models/category_model.dart';
import 'package:promohunter/models/price_movement_model.dart';
import 'package:promohunter/models/product_model.dart';
import 'package:promohunter/models/product_request_model.dart';
import 'package:promohunter/models/settings_model.dart';
import 'package:promohunter/models/shop_model.dart';
import 'package:promohunter/models/user_model.dart';
import 'package:promohunter/utils/auth_client.dart';
import 'package:promohunter/utils/database_client.dart';
import 'package:promohunter/widgets/error_pop_up.dart';
import 'package:quiver/strings.dart';

class HomeProvider extends ChangeNotifier {
  SettingsModel settingsModel;

  List<ProductModel> products = [];
  List<AdModel> ads = [];
  List<ProductModel> deals = [];
  List<BrochuresModel> brochures = [];
  List<ProductModel> fav = [];
  List<CartItemModel> cart = [];
  List<CategoryModel> categories = [];
  List<BrandModel> brands = [];
  List<ShopModel> shops = [];

  // Filtered Lists
  List<String> promoShop = [];
  List<ProductModel> filteredProducts = [];

  List<ProductModel> filteredDeals = [];
  List<ProductModel> filteredFav = [];
  List<CartItemModel> filteredCart = [];
  bool canPop = true;

  // cart stuff
  num totalCartPrice = 0;
  num maxTotalCartPrice = 0;
  num totalCartDiscount = 0;

  // selection stuff
  ShopModel selectedShop;
  List<ProductModel> resultProducts = [];
  List<ProductModel> selectedProducts = [];
  ProductModel singleSelectedProduct;
  AlternatePriceModel selectedProductAlternatePrice;

  // Achievements and Points
  PointsPerAchievementsModel pointsPerAchievements;

  HomeProvider() {
    getSettings();
    getBrands();
    getShops();
    getAds();
    getCategories();
    getProducts();
    getBrochures();
    getPromoShop();
  }

  Future<void> getSettings() async {
    settingsModel = await DatabaseClient.instance.getSettings();
    pointsPerAchievements =
        await DatabaseClient.instance.getAchievementsPoints();
    notifyListeners();
  }

  Future<void> getProducts() async {
    products = await DatabaseClient.instance.getProducts();
    filteredProducts = List.of(products, growable: true);
    notifyListeners();
    getDeals();
  }

  Future<void> getBrochures() async {
    brochures = await DatabaseClient.instance.getBrochures();
    for (BrochuresModel brochuresModel in brochures) {
      if (brochuresModel.show) await brochuresModel.getShop();
    }
    notifyListeners();
  }

  List<String> getPromoShop() {
    for (final product in products) {
      if (product.alternatePrices.isNotEmpty) {
        for (int i = 0; i < product.alternatePrices.length; i++) {
          if (!promoShop.contains(product.alternatePrices[i].shopName)) {
            promoShop.add(product.alternatePrices[i].shopName);
            notifyListeners();
          }
        }
      }
    }
    for (int i = 0; i < promoShop.length; i++) {
      print(promoShop[i]);
    }
    return promoShop;
  }

  Future<void> getDeals() async {
    for (final product in products) {
      if (product.alternatePrices.isNotEmpty && !deals.contains(product))
        deals.add(product);
    }
    filteredDeals = List.of(deals, growable: true);
    notifyListeners();
  }

  Future<void> getAds() async {
    ads = await DatabaseClient.instance.getAds();
    notifyListeners();
  }

  Future<void> getFav(List<String> favIds) async {
    for (String id in favIds) {
      final product = await DatabaseClient.instance.getProduct(id);
      if (fav.where((element) => element.id == product.id).isEmpty)
        fav.add(product);
    }

    filteredFav = List.of(fav, growable: true);
    notifyListeners();
  }

  Future<void> getCart(List<CartItemModel> cartIds) async {
    for (CartItemModel cartItemModel in cartIds) {
      final product = await DatabaseClient.instance
          .getProduct(cartItemModel.productModelId);
      if (cart.where((element) => element.productModelId == product.id).isEmpty)
        cartItemModel.setProductModel(product);
    }
    cart = cartIds;
    if (cart.isNotEmpty) {
      totalCartPrice = 0;
      maxTotalCartPrice = 0;
      for (final c in cart) {
        if (c.productModel == null)
          await c.setProductModel(
              await DatabaseClient.instance.getProduct(c.productModelId));
        totalCartPrice += (c.productModel.minPrice * c.quantity);
        maxTotalCartPrice += (c.productModel.basicPrice * c.quantity);
      }
      totalCartDiscount = maxTotalCartPrice - totalCartPrice;
    }
    filteredCart = List.of(cart, growable: true);
    notifyListeners();
  }

  Future<void> addToCart(CartItemModel cartItemModel) async {
    if (cart
        .where(
            (element) => element.productModelId == cartItemModel.productModelId)
        .isNotEmpty) return;
    cart.add(cartItemModel);
    filteredCart.add(cartItemModel);
    totalCartPrice += cartItemModel.productModel.minPrice;
    maxTotalCartPrice += cartItemModel.productModel.basicPrice;
    totalCartDiscount = maxTotalCartPrice - totalCartPrice;
    notifyListeners();
    cartItemModel.setProductModel(
        await DatabaseClient.instance.getProduct(cartItemModel.productModelId));
  }

  void remFromCart(String productModelId) {
    CartItemModel cartItemModel = cart.firstWhere(
        (element) => element.productModelId == productModelId,
        orElse: null);

    if (cartItemModel == null) return;

    cart.removeWhere((element) => element.productModelId == productModelId);
    filteredCart
        .removeWhere((element) => element.productModelId == productModelId);
    totalCartPrice -= cartItemModel.productModel.minPrice;
    maxTotalCartPrice -= cartItemModel.productModel.basicPrice;
    totalCartDiscount = maxTotalCartPrice - totalCartPrice;
    notifyListeners();
  }

  void changeTotalCartPrice(num basic, num min, bool isAdd) {
    if (isAdd) {
      totalCartPrice += min;
      maxTotalCartPrice += basic;
      totalCartDiscount = maxTotalCartPrice - totalCartPrice;
    } else {
      totalCartPrice -= min;
      maxTotalCartPrice -= basic;
      totalCartDiscount = maxTotalCartPrice - totalCartPrice;
    }
    notifyListeners();
  }

  Future<void> getCategories() async {
    categories = await DatabaseClient.instance.getCategories();
    notifyListeners();
  }

  Future<void> getBrands() async {
    brands = await DatabaseClient.instance.getBrands();
    notifyListeners();
  }

  Future<void> getShops() async {
    shops = await DatabaseClient.instance.getShops();
    notifyListeners();
  }

  void selectShop(ShopModel shopModel) {
    selectedShop = shopModel;
    selectedProductAlternatePrice =
        singleSelectedProduct.alternatePrices.firstWhere(
      (element) => element.shopId == selectedShop.id,
      orElse: () => null,
    );
    notifyListeners();
  }

  void selectSingleSelectedProduct(ProductModel productModel) {
    singleSelectedProduct = productModel;
    notifyListeners();
  }

  Future<void> selectProduct(BuildContext context, String search,
      {bool brandSelected = false}) async {
    resultProducts = [];
    selectedProducts = [];
    singleSelectedProduct = null;

    if (brandSelected) {
      resultProducts = List.of(products
          .where(
            (element) =>
                element.name.contains(RegExp(search, caseSensitive: false)) &&
                element.brandId == selectedShop?.id,
          )
          .toList());

      if (resultProducts.length == 1)
        singleSelectedProduct = resultProducts.first;

      if (singleSelectedProduct != null)
        selectedProductAlternatePrice =
            singleSelectedProduct.alternatePrices.firstWhere(
          (element) => element.shopId == selectedShop.id,
          orElse: () => null,
        );
    } else {
      resultProducts = List.of(products
          .where(
            (element) =>
                element.name.contains(RegExp(search, caseSensitive: false)),
          )
          .toList());

      if (resultProducts.length == 1)
        singleSelectedProduct = resultProducts.first;
    }

    notifyListeners();
  }

  Future<bool> selectProductByQBarcode(BuildContext context) async {
    resultProducts = [];
    selectedProducts = [];
    singleSelectedProduct = null;

    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.QR);

    if (barcodeScanRes == null || barcodeScanRes == '-1') return false;

//    if (brandSelected) {
//      resultProducts = List.of(products
//          .where(
//            (element) =>
//                element.barcode == barcodeScanRes &&
//                element.brandId == selectedShop?.id,
//          )
//          .toList());
//
//      if (resultProducts.length == 1)
//        singleSelectedProduct = resultProducts.first;
//    } else {
    resultProducts = List.of(products
        .where(
          (element) => element.barcode == barcodeScanRes,
        )
        .toList());

    if (resultProducts.length == 1)
      singleSelectedProduct = resultProducts.first;
//    }

    notifyListeners();

    return true;
  }

  Future<void> confirmPrice() async {
    selectedProductAlternatePrice.confirmedBy++;
    selectedProductAlternatePrice.lastUpdated = DateTime.now();

    singleSelectedProduct.alternatePrices[singleSelectedProduct.alternatePrices
            .indexOf(singleSelectedProduct.alternatePrices
                .firstWhere((element) => element.shopId == selectedShop.id))] =
        selectedProductAlternatePrice;

    await DatabaseClient.instance.updateProduct(singleSelectedProduct);
  }

  Future<void> updatePrice(String price, UserModel user) async {
    num pri = price.contains('.') ? double.parse(price) : int.parse(price);

    if (selectedProductAlternatePrice == null) {
      selectedProductAlternatePrice = AlternatePriceModel();
      selectedProductAlternatePrice.confirmedBy = 1;
      selectedProductAlternatePrice.lastUpdated = DateTime.now();
      selectedProductAlternatePrice.price = pri;
      selectedProductAlternatePrice.shopId = selectedShop.id;
      selectedProductAlternatePrice.shopName = selectedShop.name;
      singleSelectedProduct.alternatePrices.add(selectedProductAlternatePrice);

      await DatabaseClient.instance.updateProduct(singleSelectedProduct);
    } else {
      if (selectedProductAlternatePrice.price == pri) {
        await confirmPrice();
        return;
      }

      num percentage = pri / singleSelectedProduct.basicPrice;

      selectedProductAlternatePrice.confirmedBy = 1;
      selectedProductAlternatePrice.lastUpdated = DateTime.now();
      selectedProductAlternatePrice.price = pri;

      singleSelectedProduct.alternatePrices[singleSelectedProduct
              .alternatePrices
              .indexOf(singleSelectedProduct.alternatePrices.firstWhere(
                  (element) => element.shopId == selectedShop.id))] =
          selectedProductAlternatePrice;

      PriceMovementModel priceMovement = PriceMovementModel();
      priceMovement.productId = singleSelectedProduct.id;
      priceMovement.shopId = selectedShop.id;
      priceMovement.userId = await AuthClient.instance.uid();
      priceMovement.price = pri;
      priceMovement.date = DateTime.now();

      if (percentage <= settingsModel.percentage) {
        priceMovement.status = 'Validated';
        await DatabaseClient.instance.updateProduct(singleSelectedProduct);

        await DatabaseClient.instance
            .updatePricePoint(user, pointsPerAchievements);
      } else {
        priceMovement.status = 'NotValidated';
        await DatabaseClient.instance.putPriceRequest(priceMovement);
      }

      await DatabaseClient.instance.putPriceMovement(priceMovement);
    }
  }

  bool checkPromo(BuildContext context, ProductModel product, UserModel user) {
    singleSelectedProduct = product;
    if (product.alternatePrices.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) =>
            ErrorPopUp(message: 'No Promos were found for this Product'),
      );
      return false;
    }

    DatabaseClient.instance.updatePromoHuntPoints(user, pointsPerAchievements);

    return true;
  }

  Future<void> addProductToCart(UserModel currentUser) async {
    if (singleSelectedProduct != null) {
      currentUser.cartIds.add(CartItemModel(singleSelectedProduct.id, 1));
      addToCart(CartItemModel(singleSelectedProduct.id, 1));

      singleSelectedProduct.noOfCart++;

      notifyListeners();

      await DatabaseClient.instance.updateUserData(currentUser);
      await DatabaseClient.instance.updateProduct(singleSelectedProduct);
      await DatabaseClient.instance.updateProductsInListPoints(currentUser);

      return;
    }

    if (selectedProducts.isNotEmpty) {
      for (ProductModel p in selectedProducts) {
        currentUser.cartIds.add(CartItemModel(p.id, 1));

        p.noOfCart++;

        await DatabaseClient.instance.updateUserData(currentUser);
        await DatabaseClient.instance.updateProduct(p);
        await DatabaseClient.instance.updateProductsInListPoints(currentUser);
      }
      notifyListeners();
      return;
    }
  }

  void toSelected(ProductModel product) {
    if (selectedProducts.where((element) => element.id == product.id).isEmpty) {
      selectedProducts.add(product);
    } else {
      selectedProducts.remove(product);
    }

    notifyListeners();
  }

  Future<void> sendProductRequest(
      ProductRequestModel request, UserModel user) async {
    await DatabaseClient.instance.requestProduct(request);
    await DatabaseClient.instance
        .updateProductsRequestedPoints(user, pointsPerAchievements);
  }

  Future<void> updateUser(UserModel userModel) async {
    await DatabaseClient.instance.updateUserData(userModel);
  }

  // search methods
  void searchProducts(String search) {
    filteredProducts = List.of(
      products
          .where((element) =>
              element.name.startsWith(RegExp(search, caseSensitive: false)))
          .toList(),
      growable: true,
    );
    canPop = false;
    notifyListeners();
  }

  void searchDeals(String search) {
    filteredDeals = List.of(
      deals
          .where((element) =>
              element.name.startsWith(RegExp(search, caseSensitive: false)))
          .toList(),
      growable: true,
    );
    canPop = false;
    notifyListeners();
  }

  void searchFav(String search) {
    filteredFav = List.of(
      fav
          .where((element) =>
              element.name.startsWith(RegExp(search, caseSensitive: false)))
          .toList(),
      growable: true,
    );
    canPop = false;
    notifyListeners();
  }

  void searchCart(String search) {
    filteredCart = List.of(
      cart
          .where((element) => element.productModel.name
              .startsWith(RegExp(search, caseSensitive: false)))
          .toList(),
      growable: true,
    );
    canPop = false;
    notifyListeners();
  }

  void resetLists() {
    filteredProducts = List.of(products, growable: true);
    filteredDeals = List.of(deals, growable: true);
    filteredFav = List.of(fav, growable: true);
    filteredCart = List.of(cart, growable: true);
    notifyListeners();
  }

  bool toggleCanPop() {
    canPop = true;
    return false;
  }

  void filterLibProducts(CategoryModel categoryModel) {
    filteredProducts = List.of(
        products.where((element) => element.catId == categoryModel.id).toList(),
        growable: true);
    for (int i = 0; i < filteredProducts.length; i++) {
      print(filteredProducts[i].name);
    }
  }

  bool returnShop(List<AlternatePriceModel> alternatePrices, String sName) {
    for (int i = 0; i < alternatePrices.length; i++) {
      if (alternatePrices[i].shopName == sName) {
        return true;
      }
    }
    return false;
  }

  void filterPromoShopProducts(String shopName2) {
    // ignore: unused_local_variable
    for (final product in products) {
      // print(products);
      // if (product.alternatePrices.isNotEmpty) {

      filteredProducts = List.of(products.where((element) =>
          element.alternatePrices.isNotEmpty &&
          returnShop(element.alternatePrices, shopName2) == true));
      // for (int i = 0; i < product.alternatePrices.length; i++) {

      //   filteredProducts = List.of(
      //       products
      //           .where((element) =>
      //               element.alternatePrices[i].shopName == shopName2)
      //           .toList(),
      //       growable: true);

      // }
      // }
    }
  }

  void filterDeals(String cat, String brand) {
    if (isBlank(cat) && isBlank(brand)) return;

    CategoryModel categoryModel;
    if (!isBlank(cat) && isBlank(brand)) {
      categoryModel = categories.firstWhere(
        (element) => element.name.startsWith(
          RegExp(
            cat,
            caseSensitive: false,
          ),
        ),
        orElse: () => null,
      );

      if (categoryModel == null) {
        return;
      }

      filteredDeals =
          List.of(deals.where((element) => element.catId == categoryModel.id));
    }

    BrandModel brandModel;
    if (!isBlank(brand) && isBlank(cat)) {
      brandModel = brands.firstWhere(
        (element) => element.name.startsWith(
          RegExp(
            cat,
            caseSensitive: false,
          ),
        ),
        orElse: () => null,
      );

      if (brandModel == null) {
        return;
      }

      filteredDeals =
          List.of(deals.where((element) => element.brandId == brandModel.id));
    }

    if (!isBlank(brand) && !isBlank(cat)) {
      categoryModel = categories.firstWhere(
        (element) => element.name.startsWith(
          RegExp(
            cat,
            caseSensitive: false,
          ),
        ),
        orElse: () => null,
      );

      brandModel = brands.firstWhere(
        (element) => element.name.startsWith(
          RegExp(
            cat,
            caseSensitive: false,
          ),
        ),
        orElse: () => null,
      );

      if (categoryModel == null && brandModel != null) {
        filteredDeals =
            List.of(deals.where((element) => element.brandId == brandModel.id));
      }

      if (brandModel == null && categoryModel != null) {
        filteredDeals = List.of(
            deals.where((element) => element.catId == categoryModel.id));
      }

      if (brandModel != null && categoryModel != null) {
        filteredDeals = List.of(deals.where((element) =>
            element.catId == categoryModel.id &&
            element.brandId == brandModel.id));
      }
    }

    canPop = false;
    notifyListeners();
  }

  void filterProducts(String cat, String brand) {
    if (isBlank(cat) && isBlank(brand)) return;

    CategoryModel categoryModel;
    if (!isBlank(cat) && isBlank(brand)) {
      categoryModel = categories.firstWhere(
        (element) => element.name.startsWith(
          RegExp(
            cat,
            caseSensitive: false,
          ),
        ),
        orElse: () => null,
      );

      if (categoryModel == null) {
        return;
      }

      filteredProducts = List.of(
          products.where((element) => element.catId == categoryModel.id));
    }

    BrandModel brandModel;
    if (!isBlank(brand) && isBlank(cat)) {
      brandModel = brands.firstWhere(
        (element) => element.name.startsWith(
          RegExp(
            cat,
            caseSensitive: false,
          ),
        ),
        orElse: () => null,
      );

      if (brandModel == null) {
        return;
      }

      filteredProducts = List.of(
          products.where((element) => element.brandId == brandModel.id));
    }

    if (!isBlank(brand) && !isBlank(cat)) {
      categoryModel = categories.firstWhere(
        (element) => element.name.startsWith(
          RegExp(
            cat,
            caseSensitive: false,
          ),
        ),
        orElse: () => null,
      );

      brandModel = brands.firstWhere(
        (element) => element.name.startsWith(
          RegExp(
            cat,
            caseSensitive: false,
          ),
        ),
        orElse: () => null,
      );

      if (categoryModel == null && brandModel != null) {
        filteredProducts = List.of(
            products.where((element) => element.brandId == brandModel.id));
      }

      if (filteredProducts == null && categoryModel != null) {
        filteredCart = List.of(cart.where(
            (element) => element.productModel.catId == categoryModel.id));
      }

      if (brandModel != null && categoryModel != null) {
        filteredProducts = List.of(products.where((element) =>
            element.catId == categoryModel.id &&
            element.brandId == brandModel.id));
      }
    }

    canPop = false;
    notifyListeners();
  }

  void filterFav(String cat, String brand) {
    if (isBlank(cat) && isBlank(brand)) return;

    CategoryModel categoryModel;
    if (!isBlank(cat) && isBlank(brand)) {
      categoryModel = categories.firstWhere(
        (element) => element.name.startsWith(
          RegExp(
            cat,
            caseSensitive: false,
          ),
        ),
        orElse: () => null,
      );

      if (categoryModel == null) {
        return;
      }

      filteredFav =
          List.of(fav.where((element) => element.catId == categoryModel.id));
    }

    BrandModel brandModel;
    if (!isBlank(brand) && isBlank(cat)) {
      brandModel = brands.firstWhere(
        (element) => element.name.startsWith(
          RegExp(
            cat,
            caseSensitive: false,
          ),
        ),
        orElse: () => null,
      );

      if (brandModel == null) {
        return;
      }

      filteredFav =
          List.of(fav.where((element) => element.brandId == brandModel.id));
    }

    if (!isBlank(brand) && !isBlank(cat)) {
      categoryModel = categories.firstWhere(
        (element) => element.name.startsWith(
          RegExp(
            cat,
            caseSensitive: false,
          ),
        ),
        orElse: () => null,
      );

      brandModel = brands.firstWhere(
        (element) => element.name.startsWith(
          RegExp(
            cat,
            caseSensitive: false,
          ),
        ),
        orElse: () => null,
      );

      if (categoryModel == null && brandModel != null) {
        filteredFav =
            List.of(fav.where((element) => element.brandId == brandModel.id));
      }

      if (brandModel == null && categoryModel != null) {
        filteredFav =
            List.of(fav.where((element) => element.catId == categoryModel.id));
      }

      if (brandModel != null && categoryModel != null) {
        filteredFav = List.of(fav.where((element) =>
            element.catId == categoryModel.id &&
            element.brandId == brandModel.id));
      }
    }

    canPop = false;
    notifyListeners();
  }

  void filterCart(String cat, String brand) {
    if (isBlank(cat) && isBlank(brand)) return;

    CategoryModel categoryModel;
    if (!isBlank(cat) && isBlank(brand)) {
      categoryModel = categories.firstWhere(
        (element) => element.name.startsWith(
          RegExp(
            cat,
            caseSensitive: false,
          ),
        ),
        orElse: () => null,
      );

      if (categoryModel == null) {
        return;
      }

      filteredCart = List.of(cart
          .where((element) => element.productModel.catId == categoryModel.id));
    }

    BrandModel brandModel;
    if (!isBlank(brand) && isBlank(cat)) {
      brandModel = brands.firstWhere(
        (element) => element.name.startsWith(
          RegExp(
            cat,
            caseSensitive: false,
          ),
        ),
        orElse: () => null,
      );

      if (brandModel == null) {
        return;
      }

      filteredCart = List.of(cart
          .where((element) => element.productModel.brandId == brandModel.id));
    }

    if (!isBlank(brand) && !isBlank(cat)) {
      categoryModel = categories.firstWhere(
        (element) => element.name.startsWith(
          RegExp(
            cat,
            caseSensitive: false,
          ),
        ),
        orElse: () => null,
      );

      brandModel = brands.firstWhere(
        (element) => element.name.startsWith(
          RegExp(
            cat,
            caseSensitive: false,
          ),
        ),
        orElse: () => null,
      );

      if (categoryModel == null && brandModel != null) {
        filteredCart = List.of(cart
            .where((element) => element.productModel.brandId == brandModel.id));
      }

      if (brandModel == null && categoryModel != null) {
        filteredCart = List.of(cart.where(
            (element) => element.productModel.catId == categoryModel.id));
      }

      if (brandModel != null && categoryModel != null) {
        filteredCart = List.of(cart.where((element) =>
            element.productModel.catId == categoryModel.id &&
            element.productModel.brandId == brandModel.id));
      }
    }

    canPop = false;
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }
}
