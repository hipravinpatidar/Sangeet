import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:sangit/controller/language_manager.dart';
import 'package:sangit/ui_helper/custom_colors.dart';
import 'dart:math' as math;
import '../../api_service/api_services.dart';
import '../../controller/audio_manager.dart';
import '../../model/subcategory_model.dart';
import 'bhajan_list/bhajanlist_screen.dart';

class BhajanTabs extends StatefulWidget {
  const BhajanTabs(this.bannerImage, this.categoryId, this.godNameEng,this.godNameHindi);

  final String bannerImage;
  final int categoryId;
  final String godNameEng;
  final String godNameHindi;

  @override
  _BhajanTabsState createState() => _BhajanTabsState();
}

class _BhajanTabsState extends State<BhajanTabs> with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late PageController _pageController;
  late AudioPlayer audioPlayer;

  bool _isLoading = false;
  bool _controllersInitialized = false;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pageController = PageController(initialPage: 0);
    audioPlayer = AudioPlayer();
    getSubCategoryData();
  }

  Future<void> _refresh() async {
    await getSubCategoryData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  List<Datum> subcategorymodel = [];

  Future<void> getSubCategoryData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> res = await ApiService().getSubCategory(
          'https://mahakal.rizrv.in/api/v1/sangeet/get-by-sangeet-category/${widget.categoryId}');

      if (res.containsKey('status') &&
          res.containsKey('data') &&
          res['data'] != null) {
        final SubCategoryModel subCategoryModel =
            SubCategoryModel.fromJson(res);

        if (subCategoryModel.status == 200) {
          // check the status code
          setState(() {
            subcategorymodel = subCategoryModel.data;
            _isLoading = false;

            _initializeControllers();
          });
        } else {
          print("Error fetching subcategory data: ${subCategoryModel.status}");
        }
      } else {
        print("Error: 'status' or 'data' key is missing or null in response.");
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching subcategory data: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeControllers() {
    if (!_controllersInitialized) {
      _tabController = TabController(
        length: subcategorymodel.length + 1,
        vsync: this,
      );

      _tabController.addListener(() {
        if (_tabController.indexIsChanging) {
          _pageController.jumpToPage(_tabController.index);
        }
      });

      _pageController = PageController(
        initialPage: 0,
      );

      _pageController.addListener(() {
        if (_pageController.page != null && !_tabController.indexIsChanging) {
          _tabController.animateTo(_pageController.page!.round());
        }
      });

      setState(() {
        _controllersInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    List<Datum> filteredCategories =
        subcategorymodel.where((cat) => cat.status != 0).toList();

    final List<Widget> tabs = [
      Tab(
        height: 25,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: _selectedIndex == 0 ? Colors.transparent : Colors.grey,
              )),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06, vertical: screenWidth * 0.009),
            child: Consumer<LanguageManager>(
              builder: (BuildContext context, languageManager, Widget? child) {
                return Text(
                  languageManager.nameLanguage == 'English' ? "All" : "सभी",
                  style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
        ),
      ),
      ...filteredCategories.map((cat) {
        int index = filteredCategories.indexOf(cat) + 1;
        return Tab(
          height: 25,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  //color: Colors.grey
                  color: _selectedIndex == index
                      ? Colors.transparent
                      : Colors.grey,
                )),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: screenWidth * 0.009),
              child: Consumer<LanguageManager>(
                builder:
                    (BuildContext context, languageManager, Widget? child) {
                  return Text(
                    languageManager.nameLanguage == 'English'
                        ? cat.enName
                        : cat.hiName,
                    style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
          ),
        );
      }),
    ];

    return Scaffold(
      backgroundColor: CustomColors.clrwhite,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: CustomColors.clrblack,
            ))
          : Consumer<AudioPlayerManager>(
              builder: (BuildContext context, audioManager, Widget? child) {
                return NestedScrollView(
                  controller: _scrollController,
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        stretch: false,
                        floating: false,
                        snap: false,
                        expandedHeight: screenWidth * 0.2,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(widget.bannerImage),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.04),
                                  child: Row(
                                    children: [
                                      Consumer<LanguageManager>(
                                        builder: (BuildContext context, languageManager, Widget? child) {
                                          return Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                  width: screenWidth * 0.7,
                                                  child:
                                                  Text.rich(TextSpan(children: [
                                                    TextSpan(
                                                       text:  languageManager.nameLanguage == 'English' ? "Divine Music of\n" : "संगीत संग्रह\n",

                                                        // text: "Divine Music of\n",
                                                        style: TextStyle(
                                                          fontSize:
                                                          screenWidth * 0.04,
                                                          color:
                                                          CustomColors.clrwhite,
                                                          fontWeight:
                                                          FontWeight.w500,
                                                        )),
                                                    TextSpan(
                                                        text:  languageManager.nameLanguage == 'English' ? widget.godNameEng : widget.godNameHindi,

                                                        //  text: widget.godName,
                                                        style: TextStyle(
                                                          fontSize:
                                                          screenWidth * 0.05,
                                                          color:
                                                          CustomColors.clrwhite,
                                                          fontWeight:
                                                          FontWeight.w500,
                                                        )),
                                                  ]))),
                                            ],
                                          );
                                        },
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            audioManager.togglePlayPause();
                                          });
                                        },
                                        icon: Icon(
                                          audioManager.isPlaying
                                              ? Icons.pause_circle
                                              : Icons.play_circle,
                                          size: screenWidth * 0.1,
                                          color: CustomColors.clrwhite,
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.05),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                            minHeight: 50,
                            maxHeight: 50,
                            child: Container(
                              color: Colors.white,
                              child: TabBar(
                                onTap: (index) {
                                  setState(() {
                                    _selectedIndex =
                                        index; // Update selected index on tap
                                  });
                                },
                                controller: _tabController,
                                isScrollable: true,
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.02),
                                unselectedLabelColor: CustomColors.clrblack,
                                labelColor: CustomColors.clrwhite,
                                indicatorWeight: 0.1,
                                tabAlignment: TabAlignment.start,
                                indicator: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(5)),
                                tabs: tabs,
                              ),
                            )),
                      ),
                    ];
                  },
                  body: _controllersInitialized
                      ? RefreshIndicator(
                          onRefresh: _refresh,
                          child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              BhajanList(
                                0, // Nothing will Happen By this id.
                                filteredCategories,
                                widget.godNameEng,
                                categoryId: widget.categoryId,
                                isToggle: true,
                                isAllTab: false,
                                isFixedTab: true,
                                isMusicBarVisible: true,
                              ),
                              ...filteredCategories.map((cat) => BhajanList(
                                    cat.id,
                                    filteredCategories,
                                    widget.godNameEng,
                                    categoryId: widget.categoryId,
                                    isToggle: true,
                                    isAllTab: true,
                                    isFixedTab: false,
                                    isMusicBarVisible: true,
                                  )),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ScrollController>(
        '_scrollController', _scrollController));
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
