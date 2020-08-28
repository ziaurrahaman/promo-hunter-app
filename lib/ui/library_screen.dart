import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:promohunter/providers/auth_provider.dart';
import 'package:promohunter/providers/home_provider.dart';
import 'package:promohunter/providers/product_provider.dart';
import 'package:promohunter/ui/brochure_screen.dart';
import 'package:promohunter/ui/product_screen.dart';
import 'package:promohunter/widgets/brochure_card.dart';
import 'package:promohunter/widgets/product_card.dart';
import 'package:promohunter/widgets/shopping_item_card.dart';
import 'package:provider/provider.dart';

class LibraryScreen extends StatefulWidget {
  final int index;
  final String sName;

  LibraryScreen({Key key, this.index = 0, this.sName}) : super(key: key);

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TabIndexProvider(
        TabController(
          length: 5,
          vsync: this,
          initialIndex: widget.index,
        ),
      ),
      builder: (ctx, child) => WillPopScope(
        onWillPop: () async {
          final provider = context.read<HomeProvider>();

          if (!provider.canPop) {
            provider.resetLists();
            return provider.toggleCanPop();
          } else {
            return true;
          }
        },
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: IconButton(
                  icon: Image.asset(
                    'assets/icons/filter.png',
                    color: Colors.white,
                    width: 24.0,
                    height: 24.0,
                  ),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.0),
                      ),
                    ),
                    enableDrag: true,
                    isDismissible: true,
                    isScrollControlled: true,
                    builder: (BuildContext cts) => FilterSheet(ctx),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: IconButton(
                  icon: Image.asset(
                    'assets/icons/search.png',
                    color: Colors.white,
                    width: 24.0,
                    height: 24.0,
                  ),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.0),
                      ),
                    ),
                    enableDrag: true,
                    isDismissible: true,
                    isScrollControlled: true,
                    builder: (BuildContext context) => SearchSheet(ctx),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              PreferredSize(
                preferredSize: Size(MediaQuery.of(context).size.width, 100.0),
                child: _TabBarHeader(),
              ),
              Expanded(
                child: _TabBarBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBarHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _provider = context.watch<TabIndexProvider>();
    return Material(
      elevation: 3.0,
      color: Theme.of(context).accentColor,
      child: TabBar(
        controller: _provider.tabController,
        indicatorColor: Theme.of(context).primaryColor,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white,
        labelStyle: TextStyle(
          fontFamily: 'Calibri',
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
          color: Colors.white,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Calibri',
          fontSize: 16.0,
          color: Colors.white,
        ),
        tabs: [
          Tab(
            text: 'Catalog',
          ),
          Tab(
            text: 'Promo',
          ),
          Tab(
            text: 'Brochures',
          ),
          Tab(
            text: 'Favourites',
          ),
          Tab(
            text: 'Shopping List',
          ),
        ],
      ),
    );
  }
}

class _TabBarBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _controller = context.select((TabIndexProvider m) => m.tabController);
    return TabBarView(
      controller: _controller,
      children: [
        CatalogTab(),
        PromoTab(),
        BrochuresTab(),
        FavTab(),
        ShoppingListTab(),
      ],
    );
  }
}

class CatalogTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final products = context.watch<HomeProvider>().filteredProducts;
    // final products = context.watch<HomeProvider>().filteredProducts;
    //  context.watch<HomeProvider>().filterPromoShopProducts();
    print(products.length);

    return products.isEmpty
        ? Center(
            child: Text(
              'No Products Found',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontFamily: 'Calibri',
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : GridView.builder(
            itemCount: products.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        ChangeNotifierProvider<ProductProvider>(
                      create: (context) => ProductProvider(
                        products[index],
                        context.read<AuthService>().currentUser,
                      ),
                      child: ProductScreen(),
                    ),
                  ),
                ),
                child: ChangeNotifierProvider<ProductProvider>(
                  create: (context) => ProductProvider(
                    products[index],
                    context.read<AuthService>().currentUser,
                  ),
                  child: ProductCard(),
                ),
              ),
            ),
          );
  }
}

class PromoTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deals = context.watch<HomeProvider>().filteredDeals;

    return deals.isEmpty
        ? Center(
            child: Text(
              'No Products Found',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontFamily: 'Calibri',
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : GridView.builder(
            itemCount: deals.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        ChangeNotifierProvider<ProductProvider>(
                      create: (context) => ProductProvider(
                        deals[index],
                        context.read<AuthService>().currentUser,
                      ),
                      child: ProductScreen(),
                    ),
                  ),
                ),
                child: ChangeNotifierProvider<ProductProvider>(
                  create: (context) => ProductProvider(
                    deals[index],
                    context.read<AuthService>().currentUser,
                  ),
                  child: ProductCard(),
                ),
              ),
            ),
          );
  }
}

class BrochuresTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brochures = context.watch<HomeProvider>().brochures;

    return brochures.isEmpty
        ? Center(
            child: Text(
              'No Brochures Found',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontFamily: 'Calibri',
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : ListView.builder(
            itemCount: brochures.length,
            itemBuilder: (context, index) => brochures[index].show
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              BrochureScreen(brochuresModel: brochures[index]),
                        ),
                      ),
                      child: BrochureCard(brochuresModel: brochures[index]),
                    ),
                  )
                : SizedBox(),
          );
  }
}

class FavTab extends StatefulWidget {
  @override
  _FavTabState createState() => _FavTabState();
}

class _FavTabState extends State<FavTab> {
  @override
  void initState() {
    super.initState();
    _initData();
  }

  _initData() async {
    await context.read<HomeProvider>().getFav(
          context.read<AuthService>().currentUser.favIds,
        );
  }

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<HomeProvider>().filteredFav;

    return fav.isEmpty
        ? Center(
            child: Text(
              'No Products Found',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontFamily: 'Calibri',
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : GridView.builder(
            itemCount: fav.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        ChangeNotifierProvider<ProductProvider>(
                      create: (context) => ProductProvider(
                        fav[index],
                        context.read<AuthService>().currentUser,
                      ),
                      child: ProductScreen(),
                    ),
                  ),
                ),
                child: ChangeNotifierProvider<ProductProvider>(
                  create: (context) => ProductProvider(
                    fav[index],
                    context.read<AuthService>().currentUser,
                  ),
                  child: ProductCard(),
                ),
              ),
            ),
          );
  }
}

class ShoppingListTab extends StatefulWidget {
  @override
  _ShoppingListTabState createState() => _ShoppingListTabState();
}

class _ShoppingListTabState extends State<ShoppingListTab> {
  @override
  void initState() {
    super.initState();
    _initData();
  }

  _initData() async {
    await context.read<HomeProvider>().getCart(
          context.read<AuthService>().currentUser.cartIds,
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final cart = context.watch<HomeProvider>().filteredCart;

    return cart.isEmpty
        ? Center(
            child: Text(
              'No Items Found',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontFamily: 'Calibri',
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : Container(
            color: Colors.white,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ChangeNotifierProvider<ProductProvider>(
                            create: (context) => ProductProvider(
                              cart[index].productModel,
                              context.read<AuthService>().currentUser,
                            ),
                            child: ProductScreen(),
                          ),
                        ),
                      ),
                      child: ChangeNotifierProvider<ProductProvider>(
                        create: (context) => ProductProvider(
                          cart[index].productModel,
                          context.read<AuthService>().currentUser,
                        ),
                        child: ShoppingItemCard(cart[index]),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        'Total : Rs. ',
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'sans-serif',
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${provider.totalCartPrice.toStringAsFixed(2)}/',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontFamily: 'sans-serif',
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Save up to : Rs. ${provider.totalCartDiscount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontFamily: 'sans-serif',
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
  }
}

class TabIndexProvider extends ChangeNotifier {
  final TabController tabController;

  TabIndexProvider(this.tabController) {
    tabController.addListener(() {
      notifyListeners();
    });
  }

  int get index => tabController?.index ?? 0;

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }
}

class SearchSheet extends StatefulWidget {
  final BuildContext context;

  SearchSheet(this.context);

  @override
  _SearchSheetState createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
  final _controller = TextEditingController();

  _search() {
    final provider = context.read<HomeProvider>();
    final index = widget.context.read<TabIndexProvider>().index;
    switch (index) {
      case 0:
        provider.searchProducts(_controller.text);
        Navigator.of(context).pop();
        break;
      case 1:
        provider.searchDeals(_controller.text);
        Navigator.of(context).pop();
        break;
      case 2:
        provider.searchFav(_controller.text);
        Navigator.of(context).pop();
        break;
      case 3:
        provider.searchCart(_controller.text);
        Navigator.of(context).pop();
        break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.clear,
                  size: 32.0,
                  color: Theme.of(context).accentColor,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Spacer(),
              Text(
                'Search Product',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontFamily: 'sans-serif',
                  fontSize: 20.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Image.asset(
                  'assets/icons/search.png',
                  color: Theme.of(context).accentColor,
                  height: 32.0,
                  width: 32.0,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.all(4.0),
            padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
            decoration: BoxDecoration(
              color: Color(0xFFf2f2f2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TextField(
              controller: _controller,
              style: TextStyle(
                color: Color(0xFFb3b3b3),
                fontFamily: 'sans-serif',
                fontSize: 18.0,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(0.0),
                hintText: 'Enter Product Name',
                hintStyle: TextStyle(
                  color: Color(0xFFb3b3b3),
                  fontFamily: 'sans-serif',
                  fontSize: 18.0,
                ),
                suffix: IconButton(
                  icon: Icon(Icons.clear),
                  color: Color(0xFFb3b3b3),
                  onPressed: () => _controller.clear(),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          GestureDetector(
            onTap: () => _search(),
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(4.0),
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  'Search',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'sans-serif',
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterSheet extends StatefulWidget {
  final BuildContext context;

  FilterSheet(this.context);

  @override
  _FilterSheetState createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  final _catController = TextEditingController();
  final _brandController = TextEditingController();

  _filter() {
    final provider = context.read<HomeProvider>();
    final index = widget.context.read<TabIndexProvider>().index;
    switch (index) {
      case 0:
        provider.filterProducts(_catController.text, _brandController.text);
        Navigator.of(context).pop();
        break;
      case 1:
        provider.filterDeals(_catController.text, _brandController.text);
        Navigator.of(context).pop();
        break;
      case 2:
        provider.filterFav(_catController.text, _brandController.text);
        Navigator.of(context).pop();
        break;
      case 3:
        provider.filterCart(_catController.text, _brandController.text);
        Navigator.of(context).pop();
        break;
    }
  }

  @override
  void dispose() {
    _catController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.clear,
                  size: 32.0,
                  color: Theme.of(context).accentColor,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Spacer(),
              Text(
                'Filter By',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontFamily: 'sans-serif',
                  fontSize: 20.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Image.asset(
                  'assets/icons/search.png',
                  color: Theme.of(context).accentColor,
                  height: 32.0,
                  width: 32.0,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'By Category',
              style: TextStyle(
                color: Color(0xFFb3b3b3),
                fontFamily: 'sans-serif',
                fontSize: 18.0,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.all(4.0),
            padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
            decoration: BoxDecoration(
              color: Color(0xFFf2f2f2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TextField(
              controller: _catController,
              style: TextStyle(
                color: Color(0xFFb3b3b3),
                fontFamily: 'sans-serif',
                fontSize: 18.0,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(0.0),
                hintText: 'Select Category',
                hintStyle: TextStyle(
                  color: Color(0xFFb3b3b3),
                  fontFamily: 'sans-serif',
                  fontSize: 18.0,
                ),
                suffix: IconButton(
                  icon: Icon(Icons.clear),
                  color: Color(0xFFb3b3b3),
                  onPressed: () => _catController.clear(),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'By Brand',
              style: TextStyle(
                color: Color(0xFFb3b3b3),
                fontFamily: 'sans-serif',
                fontSize: 18.0,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.all(4.0),
            padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
            decoration: BoxDecoration(
              color: Color(0xFFf2f2f2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TextField(
              controller: _brandController,
              style: TextStyle(
                color: Color(0xFFb3b3b3),
                fontFamily: 'sans-serif',
                fontSize: 18.0,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(0.0),
                hintText: 'Select Brand',
                hintStyle: TextStyle(
                  color: Color(0xFFb3b3b3),
                  fontFamily: 'sans-serif',
                  fontSize: 18.0,
                ),
                suffix: IconButton(
                  icon: Icon(Icons.clear),
                  color: Color(0xFFb3b3b3),
                  onPressed: () => _brandController.clear(),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          GestureDetector(
            onTap: () => _filter(),
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(4.0),
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  'Filter',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'sans-serif',
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
