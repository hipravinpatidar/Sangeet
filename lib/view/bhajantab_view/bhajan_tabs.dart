import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:sangit/ui_helper/custom_colors.dart';
import 'dart:math' as math;
import '../../api_service/api_services.dart';
import '../../controller/audio_manager.dart';
import '../../model/subcategory_model.dart';
import 'bhajan_list/bhajanlist_screen.dart';


class BhajanTabs extends StatefulWidget {
  const BhajanTabs(this.bannerImage, this.categoryId, this.godName, {Key? key}):super(key: key);

  final String bannerImage;
  final int categoryId;
  final String godName;

  @override
  _BhajanTabsState createState() => _BhajanTabsState();
}

class _BhajanTabsState extends State<BhajanTabs> with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late PageController _pageController;
  late AudioPlayer audioPlayer;

  List<SubCategoryModel> subcategorymodel = <SubCategoryModel>[];
  bool _isLoading = false;
  bool _controllersInitialized = false;

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

  Future<void> getSubCategoryData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final res = await ApiService().getSubCategory(
          'https://mahakal.rizrv.in/api/v1/sangeet/get-by-sangeet-category/${widget.categoryId}');
      List<dynamic> listSubcategory = res;
      setState(() {
        subcategorymodel.clear();
        subcategorymodel
            .addAll(listSubcategory.map((e) => SubCategoryModel.fromJson(e)));
        _isLoading = false;
        _initializeControllers();
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching subcategory data: $error");
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

    List<SubCategoryModel> filteredCategories =
        subcategorymodel.where((cat) => cat.status != 0).toList();

    final List<Widget> tabs = [
      Tab(
        height: 25,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.grey)),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06, vertical: screenWidth * 0.009),
            child: Text(
              "All",
              style: TextStyle(
                  fontSize: screenWidth * 0.03, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      ...filteredCategories
          .map(
            (cat) => Tab(
              height: 25,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey)),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenWidth * 0.009),
                  child: Text(
                    cat.name,
                    style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
    ];

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: screenWidth * 0.7,
                                            child: Text(
                                              "Divine Music of ${widget.godName}",
                                              style: TextStyle(
                                                  fontSize: screenWidth * 0.04,
                                                  color: CustomColors.clrwhite,
                                                  fontWeight: FontWeight.w500,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                              maxLines: 1,
                                            ),
                                          ),
                                          Text(
                                            "55000 Total Devotee Listened",
                                            style: TextStyle(
                                                fontSize: screenWidth * 0.03,
                                                color: CustomColors.clrggreytxt,
                                                fontWeight: FontWeight.w500,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                      Spacer(),
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
                                      SizedBox(width: screenWidth * 0.05)
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
                           // children: tabviews,
                            children: [

                              BhajanList(2,subcategorymodel, widget.godName, categoryId: widget.categoryId, isToggle: true, isAllTab: false,
                                isFixedTab: true, isMusicBarVisible: true,),
                              ...filteredCategories
                                  .map((cat) => BhajanList(
                                cat.id,
                                filteredCategories,
                                widget.godName,
                                categoryId: widget.categoryId,
                                isToggle: true,
                                  isAllTab: true,
                                  isFixedTab: false, isMusicBarVisible: true,
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
