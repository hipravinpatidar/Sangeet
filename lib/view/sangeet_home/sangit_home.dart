import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sangit/controller/language_manager.dart';
import 'package:sangit/ui_helper/custom_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_service/api_services.dart';
import '../bhajantab_view/bhajan_tabs.dart';
import 'package:sangit/model/category_model.dart';
import '../bhajantab_view/my_favourite/favourita_screen.dart';

class SangitHome extends StatefulWidget {
  const SangitHome({required this.myLanguage});

  final String myLanguage;

  @override
  State<SangitHome> createState() => _SangitHomeState();
}

class _SangitHomeState extends State<SangitHome> {

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDataAndSetState();

    // Call getLanguageData when the widget is first created
    final languageManager =
        Provider.of<LanguageManager>(context, listen: false);
    languageManager.getLanguageData();
  }

  var categorymodel = <Datum>[];

  Future<void> _fetchDataAndSetState() async {
    setState(() {
      isLoading = true;
    });

    try {
      final Map<String, dynamic> jsonResponse = await ApiService()
          .getCategory('https://mahakal.rizrv.in/api/v1/sangeet/category');

      print(jsonResponse);
      if (jsonResponse.containsKey('status') &&
          jsonResponse.containsKey('data') &&
          jsonResponse['data'] != null) {
        final categoryModel = CategoryModel.fromJson(jsonResponse);

        setState(() {
          categorymodel = categoryModel.data;
        });
      } else {
        print("Error: 'status' or 'data' key is missing or null in response.");
      }
    } catch (error) {
      print('Error  in fetching category data: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> refresh() async {
    await _fetchDataAndSetState();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    final List<Widget> tabs = [
      Tab(
        height: MediaQuery.of(context).size.width / 6.5,
        child: Column(
          children: [

            Container(
              height: screenWidth * 0.1,
              width: screenWidth * 0.1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                image: const DecorationImage(
                  image: AssetImage("assets/image/love.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: screenWidth * 0.005,),
            SizedBox(
              width: screenHeight * 0.08,
              child:  Center(
                child: Consumer<LanguageManager>(
                  builder: (BuildContext context, languageManager, Widget? child) {
                    return  Text(
                      languageManager.selectedLanguage == 'English' ? "Favourite" : "पसंदीदा",
                      style: const TextStyle(
                          fontSize: 13,
                          color: CustomColors.clrblack,
                          overflow: TextOverflow.ellipsis),
                      maxLines: 1,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      ...categorymodel.map((cat) => Tab(
        height: MediaQuery.of(context).size.width / 6.5,
            child: Column(
              children: [
                Container(
                  height: screenWidth * 0.1,
                  width: screenWidth * 0.1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    image: DecorationImage(
                      image: NetworkImage(cat.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  width: screenHeight * 0.08,
                  child: Center(
                    child: Consumer<LanguageManager>(
                      builder: (BuildContext context, languageManager, Widget? child) {
                        return  Text(
                          // cat.hiName,

                          languageManager.selectedLanguage == 'English' ? cat.enName : cat.hiName,

                          style: const TextStyle(
                              fontSize: 13,
                              color: CustomColors.clrblack,
                              overflow: TextOverflow.ellipsis),
                          maxLines: 1,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          )),
    ];

    final List<Widget> tabViews = [
      const FavouriteScreen(),
      ...categorymodel
          .map((cat) => BhajanTabs(
                cat.banner,
                cat.id,
                cat.enName,
                cat.hiName,
                false
              ))

    ];

    return SafeArea(
      child: isLoading
          ? const Scaffold(
              backgroundColor: CustomColors.clrwhite,
              body: Center(
                  child: CircularProgressIndicator(
                color: CustomColors.clrblack,
              )))
          : categorymodel.isEmpty
              ?  Scaffold(
                  backgroundColor: CustomColors.clrwhite,
                  body:

          Column(
            children: [

              SizedBox(height: screenWidth * 0.6,),
              Center(
                child: SizedBox(
                  width: 300,
                  height: 330,
                  child: Card(
                    shadowColor: Colors.black,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Container(
                           height: 100,
                          width: 100,
                          decoration: const BoxDecoration(
                            image: DecorationImage(image: AssetImage("assets/image/connection.png"),fit: BoxFit.cover),
                            //color: Colors.red
                          ),
                        ),

                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'O',
                                style: TextStyle(fontSize: 30, color: Colors.black.withOpacity(0.8),fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'oops!',
                                style: TextStyle(fontSize: 27, color: Colors.black.withOpacity(0.8),fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Text("No Internet connection found \n Check your connection",textAlign: TextAlign.center,style: TextStyle(fontSize: screenWidth * 0.04,color: Colors.black.withOpacity(0.5)),),

                        SizedBox(height: screenWidth * 0.05,),
                        GestureDetector(
                          onTap: () {
                            _fetchDataAndSetState();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.red.withOpacity(0.7),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.2,vertical: screenWidth * 0.03),
                              child: Text("Try Again",style: TextStyle(fontSize: screenWidth * 0.04,color: Colors.white,fontWeight: FontWeight.bold),),
                            ),
                          ),
                        )

                      ],
                    ),
                  ),
                ),
              )

            ],
          )
                )
              : RefreshIndicator(
                  onRefresh: refresh,
                  color: CustomColors.clrblack,
                  backgroundColor: CustomColors.clrwhite,
                  child: DefaultTabController(
                    length: categorymodel.length + 1,
                    initialIndex: 1,
                    child: CustomScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      slivers: [
                        SliverAppBar(
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
                            ),

                          ],
                          bottom: PreferredSize(
                            preferredSize: Size.fromHeight(screenHeight * 0.08),
                            child: TabBar(
                                isScrollable: true,
                                splashFactory: NoSplash.splashFactory,
                                dividerColor: Colors.transparent,
                                tabAlignment: TabAlignment.start,
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicatorPadding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.03),
                                indicatorColor: CustomColors.clrorange,
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.01),
                                tabs: tabs),
                          ),
                        ),
                        SliverFillRemaining(
                          child: TabBarView(
                             physics: const AlwaysScrollableScrollPhysics(),
                           // physics: NeverScrollableScrollPhysics(),
                            children: tabViews,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  void _showLanguageSelectionBottomSheet(BuildContext context) {
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
                builder: (BuildContext context, languageManager, Widget? child) {
                  // Function to refresh data
                  Future<void> refreshData() async {
                    try {
                      await languageManager
                          .getLanguageData(); // Assuming this method fetches and updates the languagemodel
                    } catch (error) {
                      print("Error refreshing languages: $error");
                    }
                  }

                  // Show loading indicator if languages are being fetched
                  if (languageManager.languagemodel.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final filteredLanguages = languageManager.languagemodel
                      .where((language) => language.status == 1)
                      .toList();

                  return RefreshIndicator(
                    onRefresh: refreshData,
                    color: Colors.black, // Customize the color if needed
                    child: filteredLanguages.isEmpty
                        ? const Center(
                      child: Text('No languages available'),
                    )
                        : GridView.builder(
                         shrinkWrap: true,
                         // physics: AlwaysScrollableScrollPhysics(), // Commented to allow scroll within GridView
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
                          onTap: () async {
                            // Set the selected language in the LanguageManager
                            Provider.of<LanguageManager>(context, listen: false)
                                .setLanguage(filteredLanguages[index].enName);

                            // Save the selected language to shared preferences
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.setString('selectedLanguage', filteredLanguages[index].enName);

                            // Print the selected language
                            print("Language selected: ${filteredLanguages[index].enName}");

                            // Pop the dialog or navigate back
                            Navigator.pop(context);

                          },
                          child: LanguageContainer(
                            color: Colors.red.shade700,
                            language: filteredLanguages[index].name,
                            nameIt: filteredLanguages[index].enName,
                            isSelected: languageManager.selectedLanguage == filteredLanguages[index].enName, isRefresh: refresh,
                          ),
                        );
                      },
                    ),
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
  final bool isSelected;

  final Function isRefresh;

  const LanguageContainer({
    required this.color,
    required this.language,
    required this.nameIt,
    this.isSelected = false, required this.isRefresh,
  });

  @override
  Widget build(BuildContext context) {
    print("${isSelected}");
    var screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        // Set the selected language in the LanguageManager
        Provider.of<LanguageManager>(context, listen: false)
            .setLanguage(nameIt);

        isRefresh();

        // Print the selected language
        print("Language selected: $nameIt");

        // Pop the dialog or navigate back
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius:  isSelected ? BorderRadius.circular(10) : null,
          border: isSelected ? Border.all(color: Colors.orange,width: 8) : null,
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
