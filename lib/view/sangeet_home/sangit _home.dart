import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sangit/controller/language_manager.dart';
import 'package:sangit/model/category_model.dart';
import 'package:sangit/ui_helper/custom_colors.dart';
import 'package:sangit/view/bhajantab_view/my_favourite/favourita_screen.dart';
import '../../api_service/api_services.dart';
import '../bhajantab_view/bhajan_tabs.dart';

class SangitHome extends StatefulWidget {
  const SangitHome({Key? key, required this.myLanguage}):super(key: key);

  final String myLanguage;
  @override
  State<SangitHome> createState() => _SangitHomeState();
}

class _SangitHomeState extends State<SangitHome> {
  List<SangeetCategory> categorymodel = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCategoryData();

    // Call getLanguageData when the widget is first created
    final languageManager = Provider.of<LanguageManager>(context, listen: false);
    languageManager.getLanguageData();
  }

  Future<void> getCategoryData() async {
    try {
      final Map<String, dynamic> jsonResponse = await ApiService().getCategory('https://mahakal.rizrv.in/api/v1/sangeet/category');

      if (jsonResponse.containsKey('status') &&
          jsonResponse.containsKey('sangeetCategory') &&
          jsonResponse['sangeetCategory'] != null) {
        final categoryModel = CategoryModel.fromJson(jsonResponse);

        setState(() {
          categorymodel = categoryModel.sangeetCategory;
          isLoading = false;
        });
        print(categoryModel);
      } else {
        print(
            "Error: 'status' or 'sangeetCategory' key is missing or null in response.");
      }
    } catch (error) {
      print('Error fetching category data: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    List<SangeetCategory> filteredCategories =
        categorymodel.where((cat) => cat.status != 0).toList();

    final List<Widget> tabs = [
      Tab(
        height: 60,
        child: Column(
          children: [
            Icon(Icons.star,
                size: screenWidth * 0.1, color: CustomColors.clrorange),
            SizedBox(
              width: screenHeight * 0.08,
              child: const Center(
                child: Text(
                  'Favorites',
                  style: TextStyle(
                      fontSize: 13,
                      color: CustomColors.clrblack,
                      overflow: TextOverflow.ellipsis),
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
      ...filteredCategories.map((cat) => Tab(
            height: 60,
            child: Column(
              children: [
                Container(
                  height: screenWidth * 0.1,
                  width: screenWidth * 0.1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(cat.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  width: screenHeight * 0.08,
                  child: Center(
                    child: Text(
                      cat.name,
                      style: const TextStyle(
                          fontSize: 13,
                          color: CustomColors.clrblack,
                          overflow: TextOverflow.ellipsis),
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          )),
    ];

    final List<Widget> tabViews = [
      const FavouriteScreen(),
      ...filteredCategories
          .map((cat) => BhajanTabs(
                cat.banner,
                cat.id,
                cat.name,
              ))
          .toList(),
    ];

    return SafeArea(
      child: isLoading
          ? const Scaffold(
              backgroundColor: CustomColors.clrwhite,
              body: Center(child: CircularProgressIndicator()))
          : filteredCategories.isEmpty
              ? const Scaffold(
                  backgroundColor: CustomColors.clrwhite,
                  body: Center(child: Text('No active categories available')))
              : DefaultTabController(
                  // length: filteredCategories.length,
                  length: tabs.length,
                  child: Scaffold(
                    backgroundColor: CustomColors.clrwhite,
                    appBar: AppBar(
                      toolbarHeight: screenHeight * 0.08,
                      backgroundColor: CustomColors.clrwhite,
                      leading: Icon(
                        Icons.arrow_back,
                        size: screenWidth * 0.06,
                      ),
                      title: Text(
                        "Sangeet",
                        style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            color: CustomColors.clrorange,
                            fontWeight: FontWeight.w500),
                      ),
                      centerTitle: true,
                      actions: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05),
                          child: GestureDetector(
                              onTap: () {
                                _showLanguageSelectionBottomSheet(context);
                              },
                              child: Icon(
                                Icons.translate,
                                size: screenWidth * 0.06,
                                color: CustomColors.clrorange,
                              )),
                        )
                      ],
                      bottom: PreferredSize(
                        preferredSize: Size.fromHeight(screenHeight * 0.08),
                        child: TabBar(
                            isScrollable: true,
                            dividerColor: Colors.transparent,
                            tabAlignment: TabAlignment.start,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicatorPadding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.01),
                            indicatorColor: CustomColors.clrorange,
                            indicatorWeight: 0.5,
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.01),
                            tabs: tabs),
                      ),
                    ),
                    body: TabBarView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: tabViews),
                  ),
                ),
    );
  }

  void _showLanguageSelectionBottomSheet(BuildContext context) {
    // final languageManager = Provider.of<LanguageManager>(
    //     context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Select language for Audio / Video',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Consumer<LanguageManager>(
                builder:
                    (BuildContext context, languageManager, Widget? child) {
                  if (languageManager.languagemodel.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final filteredLanguages = languageManager.languagemodel
                      .where((language) => language.status == 1)
                      .toList();

                  return GridView.builder(
                    shrinkWrap: true,
                    //physics: AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: filteredLanguages.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                    ),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          print('LanguageContainer at index $index clicked');
                        },
                        child: LanguageContainer(
                          color: Colors.red.shade700,
                          language: filteredLanguages[index].name,
                          nameIt: filteredLanguages[index].enName,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class LanguageContainer extends StatelessWidget {
  final Color color;
  final String language;
  final String nameIt;

  const LanguageContainer({
    Key? key,
    required this.color,
    required this.language,
    required this.nameIt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        // Set the selected language in the LanguageManager
        Provider.of<LanguageManager>(context, listen: false)
            .setLanguage(language);

        // Print the selected language
        print("Language selected: $language");

        // Pop the dialog or navigate back
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          // borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: Image(
                  image: NetworkImage(
                      "https://www.shutterstock.com/image-vector/shri-mahakaleshwar-jyotirlinga-temple-vector-600nw-2447027639.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: screenWidth * 0.8,
                    child: Text(
                      language,
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nameIt,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
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
