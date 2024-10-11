import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sangit/controller/language_manager.dart';
import 'package:sangit/model/sangeet_model.dart';
import 'package:sangit/view/bhajantab_view/lyrics/lyricsbhajan.dart';
import 'package:sangit/view/music_player_screen.dart';
import '../../../api_service/api_services.dart';
import '../../../controller/audio_manager.dart';
import '../../../controller/favourite_manager.dart';
import '../../../controller/share_music.dart';
import '../../../ui_helper/custom_colors.dart';

class BhajanList extends StatefulWidget {
  BhajanList(
    this.subCategoryId,
    this.subCategoryModel,
    this.godName,
    this.godNameHindi, {
    required this.categoryId,
    required this.isToggle,
    required this.isFixedTab,
    required this.isAllTab,
    required this.isMusicBarVisible,
  });

  int subCategoryId;
  final List subCategoryModel;
  final String godName;
  final String godNameHindi;
  final int categoryId;
  final bool isToggle;
  final bool isAllTab;
  final bool isFixedTab;
  final bool isMusicBarVisible;

  @override
  State<BhajanList> createState() => _BhajanListState();
}

class _BhajanListState extends State<BhajanList>
    with SingleTickerProviderStateMixin {
  late AudioPlayerManager audioManager;
  late bool _isMusicBarVisible;

  bool _isLoading = true;
  bool isLoading = true;
  final shareMusic = ShareMusic();

  @override
  void initState() {
    super.initState();

    // By default, assume the fixed tab is selected
    if (widget.isFixedTab) {
      // Call the method to fetch data for the fixed tab
      getAllCategoryData();
      //  getAllCategoryData();// Replace this with your specific method for the fixed tab
      print("Fetching data for Fixed Tab.");
    } else if (widget.isAllTab) {
      // Call the method to fetch data for the all tab
      fetchMusicData(); // Replace this with your specific method for the all tab
      print("Fetching data for All Tab.");
    }

    // Handle refresh if needed
    _handleRefresh();

    // Set visibility based on the toggle parameter
    _isMusicBarVisible = widget.isToggle;
    print("SubModel Length Is ${widget.subCategoryModel.length}");

    // Get all category data as required
    getAllCategoryData();
    print("My SubCategory Id Is ${widget.subCategoryId}");
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Call your method to fetch data again or refresh the content
    await Future.wait([fetchMusicData(), getAllCategoryData()]);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    audioManager = Provider.of<AudioPlayerManager>(context);
  }

  // Dynamic Tabs Music List

  List<Sangeet> musiclistdata = [];

  Future<void> fetchMusicData() async {
    String currentLanguage = context.read<LanguageManager>().selectedLanguage;

    print(" My Current Selected Language Is $currentLanguage");

    try {
      final musicListResponse = await ApiService().fetchSangeetData(
        'https://mahakal.rizrv.in/api/v1/sangeet/sangeet-details?subcategory_id=${widget.subCategoryId}&language=$currentLanguage',
      );

      //  print(" My Coming Language is ${languageManager.selectedLanguage}");
      if (musicListResponse != null) {
        final sangeetModel = SangeetModel.fromJson(musicListResponse);

        setState(() {
          musiclistdata.clear();
          musiclistdata =
              sangeetModel.sangeet.where((item) => item.status == 1).toList();
          // musiclistdata = sangeetModel.sangeet;
          audioManager.setPlaylist(musiclistdata);
          _isLoading = false;
        //  _noData = false;
        });
      } else {
        print("Error: The response is null or improperly formatted.");
        setState(() {
          _isLoading = false;
         // _noData = musiclistdata.isEmpty;
         // _noData = true;
        });
      }
    } catch (error) {
      print("Failed to fetch music data: $error");
      setState(() {
        _isLoading = false;
        //_noData = true;
      });
    }
  }

  // All(Fixed Tab) Music List

  List<Sangeet> allcategorymodel = [];

  Future<void> getAllCategoryData() async {
    String currentLanguage = context.read<LanguageManager>().selectedLanguage;

    try {
      final res = await ApiService().getAllCategory(
        "https://mahakal.rizrv.in/api/v1/sangeet/sangeet-all-details?category_id=${widget.categoryId}&language=$currentLanguage",
      );

      final List<Sangeet> categoryList =
          (res as List).map((e) => Sangeet.fromJson(e)).toList();
      setState(() {
        allcategorymodel =
            categoryList.where((item) => item.status == 1).toList();
       // _noData = allcategorymodel.isEmpty;
      });
    } catch (error) {
      print("Failed to fetch all category data: $error");
      setState(() {
      });
    }
  }

  void playMusic(int index) {
    Sangeet selectedMusic;

    if (widget.isFixedTab) {
      // Assuming allcategorymodel contains Sangeet objects
      selectedMusic = allcategorymodel[index];
    } else if (widget.isAllTab) {
      selectedMusic = musiclistdata[index];
    } else {
      // Assuming subCategoryModel contains Sangeet objects
      selectedMusic = widget.subCategoryModel[index];
    }

    audioManager.playMusic(selectedMusic).then((_) {
      setState(() {
        _isMusicBarVisible = widget.isToggle;
      });
    }).catchError((error) {
      print('Error playing music: $error');
    });
  }

  void _toggleMusicBarVisibility() {
    setState(() {
      _isMusicBarVisible = !_isMusicBarVisible;
    });
  }

  Widget _buildMusicList() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading) {
      // Show loading indicator
      return Center(child: CircularProgressIndicator());
    }

    // Check if there's data in the relevant lists based on the tab type
    bool hasData;
    if (widget.isFixedTab) {
      hasData = allcategorymodel.isNotEmpty;
      print("Fixed Tab - Data Available: $hasData, Count: ${allcategorymodel.length}");
    } else if (widget.isAllTab) {
      hasData = musiclistdata.isNotEmpty;
      print("All Tab - Data Available: $hasData, Count: ${musiclistdata.length}");
    } else {
      hasData = widget.subCategoryModel.isNotEmpty; // For other tab types
      print("Subcategory Tab - Data Available: $hasData, Count: ${widget.subCategoryModel.length}");
    }

    // If no data is available, show the "No Data Here" message
    if (!hasData) {
      return Center(child: Text("No Data Here"));
    }

    // Display the list if there is data
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.isFixedTab
          ? allcategorymodel.length
          : widget.isAllTab
          ? musiclistdata.length
          : widget.subCategoryModel.length,
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
      itemBuilder: (context, index) {
        final itemData = widget.isFixedTab
            ? allcategorymodel[index]
            : widget.isAllTab
            ? musiclistdata[index]
            : widget.subCategoryModel[index];

        return InkWell(
          onTap: () => playMusic(index),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: screenWidth * 0.01,
              horizontal: screenWidth * 0.04,
            ),
            child: Row(
              children: [
                // Show the image with a play indicator if the music is currently playing
                audioManager.currentMusic != null &&
                    audioManager.isPlaying &&
                    audioManager.currentMusic!.id == itemData.id
                    ? Container(
                  height: screenHeight * 0.05,
                  width: screenWidth * 0.1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    image: DecorationImage(
                      image: NetworkImage(itemData.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: Image(
                      image: NetworkImage(
                        "https://cdn.pixabay.com/animation/2023/10/22/03/31/03-31-40-761_512.gif",
                      ),
                      color: Colors.white,
                    ),
                  ),
                )
                    : Container(
                  height: screenHeight * 0.05,
                  width: screenWidth * 0.1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    image: DecorationImage(
                      image: NetworkImage(itemData.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.4,
                        child: Text(
                          itemData.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.04,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.3,
                        child: Text(
                          itemData.singerName,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.03,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.offline_share_sharp,
                    color: Colors.orange,
                    size: screenWidth * 0.06,
                  ),
                  onPressed: () {
                    shareMusic.shareSong(itemData);
                  },
                ),
                GestureDetector(
                  onTap: () => _showBottomSheet(index),
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: Colors.orange,
                    size: screenWidth * 0.07,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Consumer<AudioPlayerManager>(
      builder: (context, audioManager, child) {
        return Scaffold(
          backgroundColor: CustomColors.clrwhite,
          body: Stack(
            children: [
              _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: CustomColors.clrblack,
                ),
              )
                  : RefreshIndicator(
                onRefresh: _handleRefresh,
                backgroundColor: CustomColors.clrwhite,
                color: CustomColors.clrblack,
                child: _buildMusicList(),
              ),
              // Music bar logic remains the same
              if (_isMusicBarVisible && audioManager.currentMusic != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    height: screenWidth * 0.19,
                    color: Colors.brown,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                MusicPlayer(
                                  widget.godNameHindi,
                                  musicData: musiclistdata,
                                  categoryId: widget.categoryId,
                                  subCategoryId: widget.subCategoryId,
                                  allcategorymodel: allcategorymodel,
                                  MyCurrentIndex: audioManager.currentIndex,
                                  subCategoryModel: widget.subCategoryModel,
                                  godName: widget.godName,
                                ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(0.0, 1.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOutCirc;
                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 1000),
                          ),
                        );
                      },
                      child: FractionallySizedBox(
                        heightFactor: 1.2,
                        widthFactor: 1.0,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: screenWidth * 0.02,
                            horizontal: screenWidth * 0.02,
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: screenWidth * 0.09,
                                    height: screenWidth * 0.09,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          audioManager.currentMusic!.image,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top: screenWidth * 0.02,
                                        left: screenWidth * 0.02,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: screenWidth * 0.5,
                                            child: Text(
                                              audioManager.currentMusic?.title ?? '',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              maxLines: 1,
                                            ),
                                          ),
                                          SizedBox(
                                            width: screenWidth * 0.5,
                                            child: Text(
                                              audioManager.currentMusic?.singerName ?? '',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          if (audioManager.isPlaying) {
                                            if (widget.isFixedTab && allcategorymodel.isNotEmpty) {
                                              int currentIndex = allcategorymodel.indexOf(audioManager.currentMusic!);
                                              if (currentIndex > 0) {
                                                audioManager.playMusic(allcategorymodel[currentIndex - 1]);
                                              } else {
                                                audioManager.playMusic(allcategorymodel.last);
                                              }
                                            } else {
                                              audioManager.skipPrevious();
                                            }
                                          }
                                        },
                                        icon: Icon(
                                          Icons.skip_previous,
                                          color: Colors.white,
                                          size: screenWidth * 0.08,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => audioManager.togglePlayPause(),
                                        child: Icon(
                                          audioManager.isPlaying ? Icons.pause_circle : Icons.play_circle,
                                          size: screenWidth * 0.08,
                                          color: CustomColors.clrwhite,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          if (audioManager.isPlaying) {
                                            if (widget.isFixedTab && allcategorymodel.isNotEmpty) {
                                              int currentIndex = allcategorymodel.indexOf(audioManager.currentMusic!);
                                              if (currentIndex < allcategorymodel.length - 1) {
                                                audioManager.playMusic(allcategorymodel[currentIndex + 1]);
                                              } else {
                                                audioManager.playMusic(allcategorymodel.first);
                                              }
                                            } else {
                                              audioManager.skipNext();
                                            }
                                          }
                                        },
                                        icon: Icon(
                                          Icons.skip_next,
                                          color: Colors.white,
                                          size: screenWidth * 0.08,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          audioManager.stopMusic();
                                          setState(() {
                                            _isMusicBarVisible = false;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.cancel,
                                          color: Colors.white,
                                          size: screenWidth * 0.08,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_upward_rounded,
                                        color: Colors.white,
                                        size: screenWidth * 0.09,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
                                child: Container(
                                  height: 5,
                                  width: double.infinity,
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      activeTrackColor: CustomColors.clrwhite,
                                      inactiveTrackColor: CustomColors.clrwhite.withOpacity(0.5),
                                      trackHeight: 1.7,
                                    ),
                                    child: Slider(
                                      min: 0.0,
                                      max: audioManager.duration?.inSeconds.toDouble() ?? 1.0,
                                      value: audioManager.currentPosition.inSeconds.toDouble().clamp(0.0, audioManager.duration?.inSeconds.toDouble() ?? 1.0),
                                      onChanged: (double value) {
                                        audioManager.seekTo(Duration(seconds: value.toInt()));
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String getFavouriteText(bool isFavourite, languageManager) {
    if (languageManager.selectedLanguage == 'English') {
      return isFavourite ? "Remove from Favourite" : "Add to Favourite";
    } else {
      return isFavourite ? "पसंदीदा से हटाएँ" : "पसंदीदा में जोड़ें";
    }
  }

  void _showBottomSheet(int index) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: CustomColors.clrwhite,
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Consumer<FavouriteProvider>(
              builder:
                  (BuildContext context, favouriteProvider, Widget? child) {

                final isFavourite = favouriteProvider.favouriteBhajan.any(
                    (favourite) =>
                        favourite!.audio ==
                        (widget.isFixedTab
                            ? allcategorymodel[index].audio
                            : musiclistdata[index].audio));

                return Consumer<LanguageManager>(
                  builder:
                      (BuildContext context, languageManager, Widget? child) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: screenHeight * 0.05,
                              width: screenWidth * 0.1,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                image: DecorationImage(
                                  image: NetworkImage((widget.isFixedTab
                                      ? allcategorymodel[index].image
                                      : widget.isAllTab
                                          ? musiclistdata[index].image
                                          : widget
                                              .subCategoryModel[index].image)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.03),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: screenWidth * 0.4,
                                    child: Text(
                                      (widget.isFixedTab
                                          ? allcategorymodel[index].title
                                          : widget.isAllTab
                                              ? musiclistdata[index].title
                                              : widget.subCategoryModel[index]
                                                  .title),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.04,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(
                                    width: screenWidth * 0.3,
                                    child: Text(
                                      (widget.isFixedTab
                                          ? allcategorymodel[index].singerName
                                          : widget.isAllTab
                                              ? musiclistdata[index].singerName
                                              : widget.subCategoryModel[index]
                                                  .singerName),
                                      style: TextStyle(
                                        color: CustomColors.clrblack,
                                        fontSize: screenWidth * 0.03,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.cancel_presentation,
                                size: screenWidth * 0.06,
                                color: CustomColors.clrblack,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        SizedBox(
                          height: screenWidth * 0.04,
                        ),

                        // GestureDetector(
                        //   onTap: () {
                        //     if (index < musiclistdata.length) {
                        //       favouriteProvider.toggleBookmark(musiclistdata[index]);
                        //       print("Added to favourite");
                        //     } else {
                        //       print("Invalid index");
                        //     }
                        //   },
                        //   child: Row(
                        //     children: [
                        //       Icon(
                        //         isFavourite ? Icons.favorite : Icons.favorite_border_sharp,
                        //         size: screenWidth * 0.06,
                        //         color: CustomColors.clrorange,
                        //       ),
                        //       SizedBox(width: screenWidth * 0.04),
                        //       Text(
                        //            "${ isFavourite ? "Remove from Favourite" : "Move to Favourite"}",
                        //            style: TextStyle(
                        //           fontSize: screenWidth * 0.04,
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),

                        GestureDetector(
                          onTap: () {
                            favouriteProvider.toggleBookmark(
                                widget.isFixedTab
                                    ? allcategorymodel[index]
                                    : musiclistdata[index],
                                isFixedTab: widget.isFixedTab);
                            print("Added to favourite");
                          },
                          child: Row(
                            children: [
                              Icon(
                                isFavourite
                                    ? Icons.favorite
                                    : Icons.favorite_border_sharp,
                                size: screenWidth * 0.06,
                                color: CustomColors.clrorange,
                              ),
                              SizedBox(width: screenWidth * 0.04),
                              Text(
                                getFavouriteText(isFavourite, languageManager),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: screenWidth * 0.04),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Lyricsbhajan(
                                      musicLyrics: widget.isFixedTab
                                          ? allcategorymodel[index].lyrics
                                          : widget.isAllTab
                                              ? musiclistdata[index].lyrics
                                              : musiclistdata[index].lyrics,
                                      musicName: widget.isFixedTab
                                          ? allcategorymodel[index].title
                                          : widget.isAllTab
                                              ? musiclistdata[index].title
                                              : musiclistdata[index].title),
                                ));
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.menu_book_outlined,
                                size: screenWidth * 0.06,
                                color: CustomColors.clrorange,
                              ),
                              SizedBox(width: screenWidth * 0.04),
                              Text(
                                languageManager.selectedLanguage == 'English'
                                    ? "View Lyrics of the Music"
                                    : "संगीत के बोल देखें",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
