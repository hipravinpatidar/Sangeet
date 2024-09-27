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
  BhajanList(this.subCategoryId, this.subCategoryModel, this.godName,this.godNameHindi,
      {
      required this.categoryId,
      required this.isToggle,
      required this.isFixedTab,
      required this.isAllTab,
      required this.isMusicBarVisible});

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
   //bool _noData = true;
   bool _noData = false;
  final shareMusic = ShareMusic();

  @override
  void initState() {
    super.initState();
    fetchMusicData();
    _handleRefresh();

    print("SubModel Length Is ${widget.subCategoryModel.length}");

    getAllCategoryData();
    _isMusicBarVisible = widget.isMusicBarVisible;
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
    String currentLanguage = context.read<LanguageManager>().nameLanguage;

    print(" My Current Selected Language Is $currentLanguage");

    try {
      final musicListResponse = await ApiService().fetchSangeetData(
        'https://mahakal.rizrv.in/api/v1/sangeet/sangeet-details?subcategory_id=${widget.subCategoryId}&language=$currentLanguage',
      );

      //  print(" My Coming Language is ${languageManager.nameLanguage}");
      if (musicListResponse != null) {
        final sangeetModel = SangeetModel.fromJson(musicListResponse);

        setState(() {
          musiclistdata.clear();
          musiclistdata = sangeetModel.sangeet.where((item) => item.status == 1).toList();
          // musiclistdata = sangeetModel.sangeet;
          audioManager.setPlaylist(musiclistdata);
          _isLoading = false;
          _noData = false;
        });
      } else {
        print("Error: The response is null or improperly formatted.");
        setState(() {
          _isLoading = false;
          _noData = musiclistdata.isEmpty;
          _noData = true;
        });
      }
    } catch (error) {
      print("Failed to fetch music data: $error");
      setState(() {
        _isLoading = false;
        _noData = true;
      });
    }
  }

  // All(Fixed Tab) Music List

  List<Sangeet> allcategorymodel = [];

  Future<void> getAllCategoryData() async {
    String currentLanguage = context.read<LanguageManager>().nameLanguage;

    try {
      final res = await ApiService().getAllCategory(
        "https://mahakal.rizrv.in/api/v1/sangeet/sangeet-all-details?category_id=${widget.categoryId}&language=$currentLanguage",
      );

      // if(res!=null){
      //
      //   setState(() {
      //     _noData = false;
      //   });

        final List<Sangeet> categoryList = (res as List).map((e) => Sangeet.fromJson(e)).toList();
        setState(() {
          allcategorymodel = categoryList.where((item) => item.status == 1).toList();
          _noData = allcategorymodel.isEmpty;
        });


    //  }
    //   else{
    //
    //     setState(() {
    //       _noData = true;
    //     });
    //
    //   }


    } catch (error) {
      print("Failed to fetch all category data: $error");
      setState(() {
       // _noData = true;

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

    return
    _noData? Center(child: Text("No Data Here")):

    ListView.builder(
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
                  audioManager.currentMusic != null &&
                          audioManager.currentMusic!.id == itemData.id
                      ? Container(
                          height: screenHeight * 0.05,
                          width: screenWidth * 0.1,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 4,
                              color: CustomColors.clrorange,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [Colors.transparent, Colors.transparent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Container(
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
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
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
                      // Icons.notifications_active_sharp,
                      Icons.offline_share_sharp,
                      color: Colors.orange,
                      size: screenWidth * 0.06,
                    ),
                    onPressed: () {
                      //_showShareBottomSheet();
                      // _shareSong(itemData);
                      shareMusic.shareSong(itemData);
                      print("Hello Data");
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
              )
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
                  ? const Center(child: CircularProgressIndicator(color: CustomColors.clrblack,))
                 // : _noData
                 // ? Center(child: Text("${"No Data"}", style: TextStyle(color: CustomColors.clrblack),))
                  : RefreshIndicator(
                      onRefresh: _handleRefresh,
                      backgroundColor: CustomColors.clrwhite,
                      color: CustomColors.clrblack,
                      child: _buildMusicList(),
                    ),
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
                            pageBuilder: (context, animation,
                                    secondaryAnimation) =>

                            MusicPlayer(widget.godNameHindi,musicData: musiclistdata, categoryId: widget.categoryId, subCategoryId: widget.subCategoryId, allcategorymodel: allcategorymodel, MyCurrentIndex: audioManager.currentIndex, subCategoryModel: widget.subCategoryModel, godName: widget.godName),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(0.0, 1.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOutCirc;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(
                                milliseconds: 1000), // Slow animation speed
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
                                          audioManager.currentMusic!.image
                                              .toString(),
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
                                          left: screenWidth * 0.02),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: screenWidth * 0.5,
                                            child: Text(
                                              audioManager.currentMusic?.title
                                                      .toString() ??
                                                  '',
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
                                              audioManager.currentMusic?.singerName
                                                      .toString() ?? '',
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


                                  // IconButton(
                                  //   onPressed: () {
                                  //     audioManager.togglePlayPause();
                                  //   },
                                  //   icon: Icon(
                                  //     audioManager.isPlaying
                                  //         ? Icons.pause_circle_filled
                                  //         : Icons.play_circle_filled,
                                  //     color: Colors.white,
                                  //     size: screenWidth * 0.1,
                                  //   ),
                                  // ),




                                  Row(
                                    children: [
                                      // Skip Previous Button
                                      IconButton(
                                        onPressed: () {
                                          if (audioManager.isPlaying) {
                                            if (widget.isFixedTab && allcategorymodel != null) {
                                              int currentIndex = allcategorymodel.indexOf(audioManager.currentMusic!);
                                              if (currentIndex > 0) {
                                                audioManager.playMusic(allcategorymodel[currentIndex - 1]);
                                              } else {
                                                audioManager.playMusic(allcategorymodel[allcategorymodel.length - 1]); // Loop back to the last song
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

                                      // Play and Pause
                                      GestureDetector(
                                        onTap: () => audioManager.togglePlayPause(),
                                        child: Icon(
                                          audioManager.isPlaying
                                              ? Icons.pause_circle
                                              : Icons.play_circle,
                                          size: screenWidth * 0.08,
                                          color: CustomColors.clrwhite,
                                        ),
                                      ),

                                      // Skip Next Button
                                      IconButton(
                                        onPressed: () {
                                          if (audioManager.isPlaying) {
                                            if (widget.isFixedTab && allcategorymodel != null) {
                                              int currentIndex = allcategorymodel.indexOf(audioManager.currentMusic!);
                                              if (currentIndex < allcategorymodel.length - 1) {
                                                audioManager.playMusic(allcategorymodel[currentIndex + 1]);
                                              } else {
                                                audioManager.playMusic(allcategorymodel[0]); // Loop back to the first song
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

                                      // Remove Music Bar
                                      IconButton(
                                        onPressed: () {
                                          audioManager.stopMusic();
                                          _toggleMusicBarVisibility();
                                        },
                                        icon: Icon(
                                          Icons.cancel,
                                          color: Colors.white,
                                          size: screenWidth * 0.08,
                                        ),
                                      ),
                                      
                                      Icon(Icons.arrow_upward_rounded,color: Colors.white,weight: 4,size: screenWidth * 0.09,)
                                      
                                    ],
                                  )




                                  // IconButton(
                                  //   onPressed: () {
                                  //     if (audioManager.isPlaying) {
                                  //       if (widget.isFixedTab &&
                                  //           allcategorymodel != null) {
                                  //         int currentIndex = allcategorymodel
                                  //             .indexOf(audioManager.currentMusic!);
                                  //         if (currentIndex <
                                  //             allcategorymodel.length - 1) {
                                  //           audioManager.playMusic(
                                  //               allcategorymodel[currentIndex + 1]);
                                  //         } else {
                                  //           audioManager.playMusic(allcategorymodel[
                                  //               0]); // Loop back to the first song
                                  //         }
                                  //       } else {
                                  //         audioManager.skipNext();
                                  //       }
                                  //     } else {
                                  //       _toggleMusicBarVisibility();
                                  //     }
                                  //   },
                                  //   icon: Icon(
                                  //     audioManager.isPlaying
                                  //         ? Icons.skip_next
                                  //         : Icons.highlight_remove_outlined,
                                  //     color: Colors.white,
                                  //     size: screenWidth * 0.1,
                                  //   ),
                                  // )
                                ],
                              ),

                              Padding(
                                padding:EdgeInsets.symmetric(vertical: screenWidth * 0.01),
                                child: Container(
                                  height: 5,
                                  width: double.infinity,
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      activeTrackColor: CustomColors.clrwhite,
                                      trackHeight: 1.7,
                                      trackShape: const RectangularSliderTrackShape(),
                                      inactiveTrackColor: CustomColors.clrwhite.withOpacity(0.5),
                                      thumbColor: CustomColors.clrwhite,
                                      thumbShape: SliderComponentShape.noThumb,
                                      overlayColor: CustomColors.clrwhite.withOpacity(0.7),
                                      valueIndicatorColor: CustomColors.clrwhite,
                                    ),
                                    child: Slider(
                                      min: 0.0,
                                      max: audioManager.duration.inSeconds.toDouble(),
                                      value: audioManager.currentPosition.inSeconds.toDouble(),
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
            child: Column(
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
                                  : widget.subCategoryModel[index].image)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
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
                                      : widget.subCategoryModel[index].title),
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
                                      : widget
                                          .subCategoryModel[index].singerName),
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
                    Spacer(),
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
                Divider(),
                SizedBox(
                  height: screenWidth * 0.04,
                ),
                GestureDetector(
                  onTap: () {
                    final favoriteProvider =
                        Provider.of<FavoriteProvider>(context, listen: false);

                    // Add musiclistdata[index] to favorites
                    favoriteProvider.addToFavorites(musiclistdata[index]);

                    // Add allcategorymodel to favorites
                    favoriteProvider.addToFavorites(allcategorymodel[index]);

                    // Close the dialog or navigate back
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: screenWidth * 0.06,
                        color: CustomColors.clrorange,
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Text(
                        "Move to Favourite",
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
                              widget.isFixedTab
                                  ? allcategorymodel[index].lyrics
                                  : widget.isAllTab
                                      ? musiclistdata[index].lyrics
                                      : musiclistdata[index].lyrics,
                              widget.isFixedTab
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
                        "View Lyrics of the Music",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
