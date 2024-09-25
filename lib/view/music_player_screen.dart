import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:sangit/controller/audio_manager.dart';
import 'package:sangit/controller/language_manager.dart';
import 'package:sangit/controller/share_music.dart';
import 'package:sangit/model/sangeet_model.dart';
import 'package:sangit/view/bhajantab_view/bhajan_list/bhajanlist_screen.dart';
import 'package:sangit/view/bhajantab_view/lyrics/lyricsbhajan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ui_helper/custom_colors.dart';

class MusicPlayer extends HookWidget {
  const MusicPlayer({
    required this.musicData,
    required this.categoryId,
    required this.subCategoryId,
    required this.allcategorymodel,
    required this.MyCurrentIndex,
    required this.subCategoryModel,
    required this.godName,
  });

  final int MyCurrentIndex;
  final List subCategoryModel;
  //final List allCategoryModel;
  final List<Sangeet> allcategorymodel;
  final String godName;
  final List musicData;
  final int categoryId;
  final int subCategoryId;

  //  bool isToggle = false;

  @override
  Widget build(BuildContext context) {
   // const collapsedBarHeight = 100.0;
   // const expandedBarHeight = 500.0;
   var expandedBarHeight = MediaQuery.of(context).size.height * 0.62;
   var collapsedBarHeight = MediaQuery.of(context).size.height * 0.12;

    final selectedIndex = useState(0);
    final scrollController = useScrollController();
    final isCollapsed = useState(false);
    final didAddFeedback = useState(false);

    var screenWidth = MediaQuery.of(context).size.width;

    List filteredCategories = subCategoryModel.where((cat) => cat.status != 0).toList();

    final List<Widget> tabs = [
      Tab(
        height: 25,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: selectedIndex.value == 0
                    ? Colors.transparent
                    : Colors.grey,
              )),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06, vertical: screenWidth * 0.009),
            child: Consumer<LanguageManager>(
              builder: (BuildContext context, languageManager, Widget? child) {
                return Text(
                  languageManager.nameLanguage == 'English' ? "All" : "सभी",
                  style: TextStyle(
                      fontSize: screenWidth * 0.03, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
        ),
      ),
      ...filteredCategories.map((cat) {int index = filteredCategories.indexOf(cat) + 1;
        return Tab(
          height: 25,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: selectedIndex.value == index
                      ? Colors.transparent
                      : Colors.grey,
                )),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: screenWidth * 0.009),
              child: Consumer<LanguageManager>(
                builder: (BuildContext context, languageManager, Widget? child) {
                  return Text(
                    languageManager.nameLanguage == 'English' ? cat.enName : cat.hiName,
                    style: TextStyle(
                        fontSize: screenWidth * 0.03, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
          ),
        );
      }),
    ];

    return Consumer<AudioPlayerManager>(
      builder: (BuildContext context, audioManager, Widget? child) {
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            isCollapsed.value = scrollController.hasClients &&
                scrollController.offset >
                    (expandedBarHeight - collapsedBarHeight);
            if (isCollapsed.value && !didAddFeedback.value) {
              HapticFeedback.mediumImpact();
              didAddFeedback.value = true;
            } else if (!isCollapsed.value) {
              didAddFeedback.value = false;
            }
            return false;
          },
          child: DefaultTabController(
            length: filteredCategories.length + 1,
            child: Stack(
              children: [
                BlurredBackdropImage(
                  audioManager: audioManager,
                ),
                NestedScrollView(
                  controller: scrollController,
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverAppBar(
                        expandedHeight: expandedBarHeight,
                        collapsedHeight: collapsedBarHeight,
                        centerTitle: false,
                        automaticallyImplyLeading: false,
                        pinned: true,
                        title: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isCollapsed.value ? 1 : 0,
                            child: CollapsedAppBarContent(
                              audioManager: audioManager,
                              musicData: musicData,
                              allcategorymodel: allcategorymodel,
                              selectedIndex:
                                  selectedIndex.value, // Cast to List<Sangeet>
                            )),
                        elevation: 0,
                        backgroundColor: isCollapsed.value
                            ? Colors.brown
                            : Colors.transparent,
                        flexibleSpace: FlexibleSpaceBar(
                          background: ExpandedAppBarContent(
                            audioManager: audioManager,
                            allcategorymodel: allcategorymodel,
                            musicData: musicData,
                            selectedIndex: selectedIndex.value,
                          ),
                        ),
                        bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(80.0),
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              color: CustomColors.clrwhite,
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: screenWidth * 0.05,
                                ),
                                Center(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.all_inclusive_outlined,
                                        size: screenWidth * 0.05,
                                        color: CustomColors.clrorange,
                                      ),
                                      SizedBox(
                                        width: screenWidth * 0.02,
                                      ),
                                      Text(
                                        "Divine Music of $godName",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        width: screenWidth * 0.02,
                                      ),
                                      Icon(
                                        Icons.all_inclusive_outlined,
                                        size: screenWidth * 0.05,
                                        color: CustomColors.clrorange,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                TabBar(
                                  onTap: (index) {
                                    selectedIndex.value = index;
                                  },
                                  isScrollable: true,
                                  dividerColor: Colors.transparent,
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
                                Divider(),
                              ],
                            ),
                          ),
                        ),
                      )
                    ];
                  },
                  body: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      BhajanList(
                        subCategoryId,
                        subCategoryModel,
                        godName,
                        categoryId: categoryId,
                        isToggle: false,
                        isFixedTab: true,
                        isAllTab: false,
                        isMusicBarVisible: false,
                      ),
                      ...filteredCategories.map((cat) => BhajanList(
                            cat.id,
                            filteredCategories,
                            godName,
                            categoryId: categoryId,
                            isToggle: false,
                            isFixedTab: false,
                            isAllTab: true,
                            isMusicBarVisible: false,
                          ))
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

class CollapsedAppBarContent extends StatefulWidget {
  final AudioPlayerManager audioManager;
  final List<Sangeet> allcategorymodel;
  final List musicData;
  final int selectedIndex;

  const CollapsedAppBarContent({
    required this.audioManager,
    required this.musicData,
    required this.allcategorymodel,
    required this.selectedIndex,
  });

  @override
  State<CollapsedAppBarContent> createState() => _CollapsedAppBarContentState();
}

class _CollapsedAppBarContentState extends State<CollapsedAppBarContent> {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Consumer<AudioPlayerManager>(
      builder: (BuildContext context, audioManager, Widget? child) {
        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02, vertical: screenWidth * 0.08),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              height: screenHeight * 0.05,
              width: screenWidth * 0.1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                image: DecorationImage(
                  image: NetworkImage(
                      audioManager.currentMusic?.image ?? 'default_image_url'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              width: screenWidth * 0.05,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: screenWidth * 0.5,
                  child: Text(
                    audioManager.currentMusic?.title ?? 'No Title',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.04,
                        overflow: TextOverflow.ellipsis,
                        color: CustomColors.clrwhite),
                    maxLines: 1,
                  ),
                ),
                SizedBox(

                  width: screenWidth * 0.4,
                  child: Text(
                    audioManager.currentMusic?.singerName ?? 'No Singer',
                    style: TextStyle(
                        color: CustomColors.clrwhite,
                        fontSize: screenWidth * 0.03,
                        overflow: TextOverflow.ellipsis),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => audioManager.togglePlayPause(),
              child: Icon(
                audioManager.isPlaying ? Icons.pause : Icons.play_arrow,
                size: screenWidth * 0.07,
                color: CustomColors.clrwhite,
              ),
            ),
            SizedBox(
              width: screenWidth * 0.05,
            ),
            GestureDetector(
              onTap: () {
                if (audioManager != null) {
                  if (widget.selectedIndex == 0) {
                    // Fixed tab logic
                    Sangeet? currentMusic = audioManager.currentMusic;

                    if (currentMusic != null) {
                      int currentIndex =
                          widget.allcategorymodel.indexOf(currentMusic);
                      print("Current music index: $currentIndex");

                      if (currentIndex != -1) {
                        if (currentIndex < widget.allcategorymodel.length - 1) {
                          // Play the next song
                          audioManager.playMusic(
                              widget.allcategorymodel[currentIndex + 1]);
                          print("Play the next song");
                        } else {
                          // Loop back to the first song
                          audioManager.playMusic(widget.allcategorymodel.first);
                          print("Loop back to the first song");
                        }
                      } else {
                        // Handle case where currentMusic is not in the list
                        if (widget.allcategorymodel.isNotEmpty) {
                          print(
                              "Handle case where currentMusic is not in the list");
                          audioManager.playMusic(widget.allcategorymodel.first);
                        } else {
                          print("No music available in the list");
                        }
                      }
                    } else {
                      // Handle case where currentMusic is null
                      if (widget.allcategorymodel.isNotEmpty) {
                        audioManager.playMusic(widget.allcategorymodel.first);
                        print("Handle case where currentMusic is null");
                      } else {
                        print("No music available in the list");
                      }
                    }
                  } else {
                    // Dynamic tab logic
                    audioManager
                        .skipNext(); // Skip to next song in the dynamic list
                    print("Skip to next song in the dynamic list");
                  }
                }
              },
              child: Icon(
                Icons.skip_next,
                color: CustomColors.clrwhite,
                size: screenWidth * 0.07,
              ),
            ),
          ]),
        );
      },
    );
  }
}

class BlurredBackdropImage extends StatelessWidget {
  final AudioPlayerManager audioManager;

  const BlurredBackdropImage({required this.audioManager});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 1.5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // The background image
          Image.network(
            audioManager.currentMusic?.image ?? 'default_image_url',
            fit: BoxFit.cover,
          ),
          // The blur effect

          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 1.5,
                sigmaY: 1.5), // Adjust the sigma values for more or less blur
           child:
            Container(color: Colors.black.withOpacity(0), // Transparent container to allow the blur effect
            ),
         ),
        ],
      ),
    );
  }
}

class ExpandedAppBarContent extends StatefulWidget {
  final AudioPlayerManager audioManager;
  final List<Sangeet> allcategorymodel;
  final List musicData;
  final int selectedIndex;

  const ExpandedAppBarContent(
      {
      required this.audioManager,
      required this.allcategorymodel,
      required this.musicData,
      required this.selectedIndex});

  @override
  State<ExpandedAppBarContent> createState() => _ExpandedAppBarContentState();
}

class _ExpandedAppBarContentState extends State<ExpandedAppBarContent> {
  String formatDuration(Duration? duration) {
    if (duration == null) return '00:00';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  final shareMusic = ShareMusic();

  void _showShuffleOptionsDialog(BuildContext context,
      AudioPlayerManager audioManager) {
    showDialog(
      context: context,
      builder: (context) {

        return ShuffleOptionsDialog(
          audioManager: audioManager,
        );
      },
    );
  }

  void playMusic(int index) {
    if (widget.audioManager != null) {
      Sangeet selectedMusic;
      if (widget.selectedIndex == 0) {
        selectedMusic = widget.allcategorymodel[index];
      } else {
        selectedMusic = widget.musicData[index];
      }
      widget.audioManager.playMusic(selectedMusic);
    }
  }

  @override
  void initState() {
    var allCategoryModel = widget.allcategorymodel;
    print(allCategoryModel);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Consumer<AudioPlayerManager>(
      builder: (BuildContext context, audiomanager, Widget? child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: screenWidth * 0.15,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_rounded,
                            size: screenWidth * 0.07,
                            color: CustomColors.clrwhite),
                    ),

                    SizedBox(width: screenWidth * 0.60,),
                    GestureDetector(
                        onTap: () {
                          shareMusic.shareSong(audiomanager.currentMusic!);
                        },
                        child: Icon(
                          Icons.share_outlined,
                          color: CustomColors.clrwhite,
                          size: screenWidth * 0.06,
                        )),
                    SizedBox(height: screenWidth * 0.05,width: screenWidth * 0.06,),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Lyricsbhajan(
                                    audiomanager.currentMusic!.lyrics,
                                    audiomanager.currentMusic!.title),
                              ));
                        },
                        child: const Icon(
                          Icons.note_alt,
                          color: CustomColors.clrwhite,
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: screenWidth * 0.24,
              ),
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: screenWidth * 0.6,
                      child: Text(
                        audiomanager.currentMusic?.title ?? 'No Title',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold,
                            color: CustomColors.clrwhite,
                            overflow: TextOverflow.ellipsis),
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(
                      width: screenWidth * 0.4,
                      child: Text(
                        audiomanager.currentMusic?.singerName ?? 'No Singer',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            color: CustomColors.clrwhite,
                            overflow: TextOverflow.ellipsis),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: CustomColors.clrwhite,
                  trackHeight: 1.5,
                  trackShape: const RectangularSliderTrackShape(),
                  inactiveTrackColor: CustomColors.clrwhite.withOpacity(0.5),
                  thumbColor: CustomColors.clrwhite,
                  overlayColor: CustomColors.clrwhite.withOpacity(0.7),
                  valueIndicatorColor: CustomColors.clrwhite,
                ),
                child: Slider(
                  min: 0.0,
                  max: audiomanager.duration.inSeconds.toDouble(),
                  value: audiomanager.currentPosition.inSeconds.toDouble(),
                  onChanged: (double value) {
                    audiomanager.seekTo(Duration(seconds: value.toInt()));
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Text(
                        formatDuration(audiomanager.currentPosition),
                        style: TextStyle(
                            color: CustomColors.clrwhite,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.04),
                        maxLines: 1,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formatDuration(audiomanager.duration),
                      style: TextStyle(
                          color: CustomColors.clrwhite,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.04),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Row(
                  children: [
                    GestureDetector(
                        onTap: () =>
                            _showShuffleOptionsDialog(context, audiomanager),
                        child: Icon(Icons.shuffle,
                            size: screenWidth * 0.08,
                            color: CustomColors.clrwhite)),
                    SizedBox(width: screenHeight * 0.07),

                    GestureDetector(
                      onTap: () {
                        if (widget.selectedIndex == 0) {
                          print("My Index is ${widget.selectedIndex}");
                          // Fixed tab logic for skip previous
                          int currentIndex = widget.allcategorymodel
                              .indexOf(audiomanager.currentMusic!);
                          if (currentIndex > 0) {
                            playMusic(currentIndex - 1);
                          } else {
                            playMusic(widget.allcategorymodel.length -
                                1); // Loop back to the last song
                          }
                        } else {
                          print("My dynamic index ${widget.selectedIndex}");
                          audiomanager
                              .skipPrevious(); // Assuming you have a skipPrevious method in your audioManager
                        }
                      },
                      child: Icon(Icons.skip_previous,
                          size: screenWidth * 0.1,
                          color: CustomColors.clrwhite),
                    ),

                    SizedBox(width: screenWidth * 0.06),
                    GestureDetector(
                      onTap: () => audiomanager.togglePlayPause(),
                      child: Icon(
                        audiomanager.isPlaying
                            ? Icons.pause_circle
                            : Icons.play_circle,
                        size: screenHeight * 0.07,
                        color: CustomColors.clrwhite,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.06),

                    GestureDetector(
                      onTap: () {
                        if (widget.selectedIndex == 0) {
                          print("My Index is ${widget.selectedIndex}");
                          // Fixed tab logic for skip next
                          int currentIndex = widget.allcategorymodel
                              .indexOf(audiomanager.currentMusic!);

                          print(" My real Current Index is ${currentIndex}");

                          if (currentIndex <
                              widget.allcategorymodel.length - 1) {
                            playMusic(currentIndex + 1);
                          } else {
                            playMusic(0); // Loop back to the first song
                          }
                        } else {
                          print("My dynamic index ${widget.selectedIndex}");
                          audiomanager
                              .skipNext(); // Assuming you have a skipNext method in your audioManager
                        }
                      },
                      child: Icon(Icons.skip_next,
                          size: screenWidth * 0.1,
                          color: CustomColors.clrwhite),
                    ),

                    Spacer(),
                    Icon(Icons.favorite_border_outlined,
                        size: screenWidth * 0.08, color: CustomColors.clrwhite)
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ShuffleOptionsDialog extends StatefulWidget {
  final AudioPlayerManager audioManager;

  const ShuffleOptionsDialog({
    required this.audioManager,
  });

  @override
  _ShuffleOptionsDialogState createState() => _ShuffleOptionsDialogState();
}

class _ShuffleOptionsDialogState extends State<ShuffleOptionsDialog> {
  int _currentSelectedIndex = 0;

  List<int> indexSelected = [
    0,1,2
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedIndex();
  }

  _loadSelectedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    int selectedIndex = prefs.getInt('selectedIndex') ?? 0;
    setState(() {
      _currentSelectedIndex = selectedIndex;
    });
  }

  _saveSelectedIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('selectedIndex', index);
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return BottomSheet(onClosing: () {

    }, builder: (context) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05,vertical: screenWidth * 0.02),
          child: Column(
            children: [

              Text(
                'How to listen to Bhajan or Arti?',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CustomColors.clrblack,
                    fontSize: screenWidth * 0.04),
              ),

              Divider(),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.fiber_smart_record_outlined,
                          color: CustomColors.clrorange, size: screenWidth * 0.05),
                      SizedBox(width: screenWidth * 0.05),
                      Text('Play Next',
                          style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: CustomColors.clrblack)),
                      Spacer(),
                      Radio<int>(
                        value: indexSelected[0],
                        groupValue: _currentSelectedIndex,
                        activeColor: CustomColors.clrorange,
                        onChanged: (int? value) {
                          setState(() {
                            _currentSelectedIndex = value!;
                          });
                          _saveSelectedIndex(value!);
                          widget.audioManager.setShuffleMode(ShuffleMode.playNext);
                         // Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.looks_one_outlined,
                          color: CustomColors.clrorange, size: screenWidth * 0.05),
                      SizedBox(width: screenWidth * 0.05),
                      Text('Play Once and Close',
                          style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: CustomColors.clrblack)),
                      Spacer(),
                      Radio<int>(
                        value: indexSelected[1],
                        groupValue: _currentSelectedIndex,
                        activeColor: CustomColors.clrorange,
                        onChanged: (int? value) {
                          setState(() {
                            _currentSelectedIndex = value!;
                          });
                          _saveSelectedIndex(value!);
                          widget.audioManager
                              .setShuffleMode(ShuffleMode.playOnceAndClose);
                         // Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  Row(
                      children: [
                        Icon(Icons.loop,
                            color: CustomColors.clrorange, size: screenWidth * 0.05),
                        SizedBox(width: screenWidth * 0.05),
                        Text('Play on Loop',
                            style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color: CustomColors.clrblack)),
                        Spacer(),
                        Radio<int>(
                          value: indexSelected[2],
                          groupValue: _currentSelectedIndex,
                          activeColor: CustomColors.clrorange,
                          onChanged: (int? value) {
                            setState(() {
                              _currentSelectedIndex = value!;
                            });
                            _saveSelectedIndex(value!);
                            widget.audioManager.setShuffleMode(ShuffleMode.playOnLoop);
                          //  Navigator.pop(context);
                          },
                        ),
                      ]),
                ],
              ),
            ],
          ),
        ),
      );
    },);
  }
}
