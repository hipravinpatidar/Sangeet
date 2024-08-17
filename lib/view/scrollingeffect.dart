import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:sangit/controller/audio_manager.dart';
import 'package:sangit/view/bhajantab_view/bhajan_list/bhajanlist_screen.dart';
import '../ui_helper/custom_colors.dart';

class MusicPlayer extends HookWidget {
  const MusicPlayer(
    this.musicData,
    this.categoryId,
    this.subCategoryId, {
    super.key,
    required this.MyCurrentIndex,
    required this.subCategoryModel,
    required this.godName,
  });

  final int MyCurrentIndex;
  final List subCategoryModel;
  final String godName;
  final List musicData;
  final int categoryId;
  final int subCategoryId;

 //  bool isToggle = false;

  @override
  Widget build(BuildContext context) {
    const collapsedBarHeight = 100.0;
    const expandedBarHeight = 500.0;

    final scrollController = useScrollController();
    final isCollapsed = useState(false);
    final didAddFeedback = useState(false);

    var screenWidth = MediaQuery.of(context).size.width;

    List filteredCategories =
        subCategoryModel.where((cat) => cat.status != 0).toList();

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
          )
          .toList(),
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
                          ),
                        ),
                        elevation: 0,
                        backgroundColor: isCollapsed.value
                            ? Colors.brown
                            : Colors.transparent,
                        flexibleSpace: FlexibleSpaceBar(
                          background: ExpandedAppBarContent(
                            audioManager: audioManager,
                          ),
                        ),
                        bottom: PreferredSize(
                          preferredSize: Size.fromHeight(80.0),
                          child: Container(
                            width: double.infinity,
                            height: 120,
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
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [

                                        Icon(Icons.ac_unit,size: screenWidth * 0.05,color: CustomColors.clrorange,),
                                        SizedBox(width: screenWidth * 0.02,),
                                        Text(
                                          "Divine Music of $godName",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.02,),
                                        Icon(Icons.ac_unit,size: screenWidth * 0.05,color: CustomColors.clrorange,),

                                      ],
                                    ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                TabBar(
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
                      BhajanList(subCategoryId, subCategoryModel, godName, categoryId: categoryId, isToggle: false, isFixedTab: true, isAllTab: false, isMusicBarVisible: false,),
                      ...filteredCategories.map((cat) =>
                          BhajanList(
                              cat.id, filteredCategories, godName,
                              categoryId: categoryId,isToggle: false, isFixedTab: false, isAllTab: true, isMusicBarVisible: false,)
                          )
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

class CollapsedAppBarContent extends StatelessWidget {
  final AudioPlayerManager audioManager;

  const CollapsedAppBarContent({Key? key, required this.audioManager})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02, vertical: screenWidth * 0.04),
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
        Spacer(),
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
          onTap: () => audioManager.skipNext(),
          child: Icon(Icons.skip_next,
              color: CustomColors.clrwhite, size: screenWidth * 0.07),
        )
      ]),
    );
  }
}

class BlurredBackdropImage extends StatelessWidget {
  final AudioPlayerManager audioManager;

  const BlurredBackdropImage({super.key, required this.audioManager});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                sigmaX: 2,
                sigmaY: 2), // Adjust the sigma values for more or less blur
            child: Container(
              color: Colors.black.withOpacity(
                  0), // Transparent container to allow the blur effect
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandedAppBarContent extends StatelessWidget {
  final AudioPlayerManager audioManager;

  ExpandedAppBarContent({super.key, required this.audioManager});

  String formatDuration(Duration? duration) {
    if (duration == null) return '00:00';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

 // List<int> myIndex = [ 0,1,2];

  void _showShuffleOptionsDialog(
      BuildContext context, AudioPlayerManager audioManager,int selectedIndex) {
    showDialog(
      context: context,
      builder: (context) {
        var screenWidth = MediaQuery.of(context).size.width;

        return ShuffleOptionsDialog(audioManager: audioManager, selectedIndex: selectedIndex,);

      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: screenWidth * 0.07,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Transform.rotate(
                    angle: 4.7,
                    child: Icon(Icons.arrow_back_ios_rounded,
                        size: screenWidth * 0.06, color: CustomColors.clrwhite),
                  ),
                ),
                Spacer(),
                Icon(Icons.share_outlined,
                    color: CustomColors.clrwhite, size: screenWidth * 0.06),
                SizedBox(width: screenWidth * 0.05),
                  Icon(Icons.note_alt_outlined,
                      size: screenWidth * 0.07, color: CustomColors.clrwhite),
              ],
            ),
          ),
          SizedBox(
            height: screenWidth * 0.3,
          ),
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: screenWidth * 0.6,
                  child: Text(
                    audioManager.currentMusic?.title ?? 'No Title',
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
                    audioManager.currentMusic?.singerName ?? 'No Singer',
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
              trackShape: RectangularSliderTrackShape(),
              inactiveTrackColor: CustomColors.clrwhite.withOpacity(0.5),
              thumbColor: CustomColors.clrwhite,
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: Text(
                    formatDuration(audioManager.currentPosition),
                    style: TextStyle(
                        color: CustomColors.clrwhite,
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.04),
                    maxLines: 1,
                  ),
                ),
                Spacer(),
                Text(
                  formatDuration(audioManager.duration),
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
                        _showShuffleOptionsDialog(context, audioManager,0),
                    child: Icon(Icons.shuffle,
                        size: screenWidth * 0.08,
                        color: CustomColors.clrwhite)),
                SizedBox(width: screenHeight * 0.07),
                GestureDetector(
                    onTap: () => audioManager.skipPrevious(),
                    child: Icon(Icons.skip_previous,
                        size: screenWidth * 0.1, color: CustomColors.clrwhite)),
                SizedBox(width: screenWidth * 0.06),
                GestureDetector(
                  onTap: () => audioManager.togglePlayPause(),
                  child: Icon(
                    audioManager.isPlaying
                        ? Icons.pause_circle
                        : Icons.play_circle,
                    size: screenHeight * 0.07,
                    color: CustomColors.clrwhite,
                  ),
                ),
                SizedBox(width: screenWidth * 0.06),
                GestureDetector(
                    onTap: () => audioManager.skipNext(),
                    child: Icon(Icons.skip_next,
                        size: screenWidth * 0.1, color: CustomColors.clrwhite)),
                Spacer(),
                Icon(Icons.favorite_border_outlined,
                    size: screenWidth * 0.08, color: CustomColors.clrwhite)
              ],
            ),
          ),
        ],
      ),
    );
  }
}




class ShuffleOptionsDialog extends StatefulWidget {
  final AudioPlayerManager audioManager;
  final int selectedIndex;  // Pass the selected index to the dialog

  ShuffleOptionsDialog({
    required this.audioManager,
    required this.selectedIndex,
  });

  @override
  _ShuffleOptionsDialogState createState() => _ShuffleOptionsDialogState();
}

class _ShuffleOptionsDialogState extends State<ShuffleOptionsDialog> {
  late int _currentSelectedIndex;

  @override
  void initState() {
    super.initState();
    _currentSelectedIndex = widget.selectedIndex; // Initialize with the passed selected index
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      backgroundColor: CustomColors.clrwhite,
      title: Text(
        'How to listen to Bhajan or Arti?',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: CustomColors.clrblack,
            fontSize: screenWidth * 0.04),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.fiber_smart_record_outlined,
                  color: CustomColors.clrorange, size: screenWidth * 0.05),
              SizedBox(width: screenWidth * 0.05),
              Text('Play Next',
                  style: TextStyle(
                      fontSize: screenWidth * 0.04, color: CustomColors.clrblack)),
              Spacer(),
              Radio<int>(
                value: 0,
                groupValue: _currentSelectedIndex,
                activeColor: CustomColors.clrorange,
                onChanged: (int? value) {
                  setState(() {
                    _currentSelectedIndex = value!;
                  });
                  widget.audioManager.setShuffleMode(ShuffleMode.playNext);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.05),
          Row(
            children: [
              Icon(Icons.looks_one_outlined,
                  color: CustomColors.clrorange, size: screenWidth * 0.05),
              SizedBox(width: screenWidth * 0.05),
              Text('Play Once and Close',
                  style: TextStyle(
                      fontSize: screenWidth * 0.04, color: CustomColors.clrblack)),
              Spacer(),
              Radio<int>(
                value: 1,
                groupValue: _currentSelectedIndex,
                activeColor: CustomColors.clrorange,
                onChanged: (int? value) {
                  setState(() {
                    _currentSelectedIndex = value!;
                  });
                  widget.audioManager.setShuffleMode(ShuffleMode.playOnceAndClose);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.05),
          Row(
            children: [
              Icon(Icons.loop,
                  color: CustomColors.clrorange, size: screenWidth * 0.05),
              SizedBox(width: screenWidth * 0.05),
              Text('Play on Loop',
                  style: TextStyle(
                      fontSize: screenWidth * 0.04, color: CustomColors.clrblack)),
              Spacer(),
              Radio<int>(
                value: 2,
                groupValue: _currentSelectedIndex,
                activeColor: CustomColors.clrorange,
                onChanged: (int? value) {
                  setState(() {
                    _currentSelectedIndex = value!;
                  });
                  widget.audioManager.setShuffleMode(ShuffleMode.playOnLoop);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}


//
// class ShuffleOptionsDialog extends StatefulWidget {
//   final AudioPlayerManager audioManager;
//
//   ShuffleOptionsDialog({required this.audioManager});
//
//   @override
//   _ShuffleOptionsDialogState createState() => _ShuffleOptionsDialogState();
// }
//
// class _ShuffleOptionsDialogState extends State<ShuffleOptionsDialog> {
//   int _selectedIndex = -1;
//
//   @override
//   Widget build(BuildContext context) {
//     var screenWidth = MediaQuery.of(context).size.width;
//
//     return AlertDialog(
//       backgroundColor: CustomColors.clrwhite,
//       title: Text(
//         'How to listen to Bhajan or Arti?',
//         style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: CustomColors.clrblack,
//             fontSize: screenWidth * 0.04),
//       ),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.fiber_smart_record_outlined,
//                   color: CustomColors.clrorange, size: screenWidth * 0.05),
//               SizedBox(width: screenWidth * 0.05),
//               Text('Play Next',
//                   style: TextStyle(
//                       fontSize: screenWidth * 0.04, color: CustomColors.clrblack)),
//               Spacer(),
//               Radio<int>(
//                 value: 0,
//                 groupValue: _selectedIndex,
//                 activeColor: CustomColors.clrorange,
//                 onChanged: (int? value) {
//                   setState(() {
//                     _selectedIndex = value!;
//                   });
//                   widget.audioManager.setShuffleMode(ShuffleMode.playNext);
//                 },
//               ),
//             ],
//           ),
//           SizedBox(height: screenWidth * 0.05),
//           Row(
//             children: [
//               Icon(Icons.looks_one_outlined,
//                   color: CustomColors.clrorange, size: screenWidth * 0.05),
//               SizedBox(width: screenWidth * 0.05),
//               Text('Play Once and Close',
//                   style: TextStyle(
//                       fontSize: screenWidth * 0.04, color: CustomColors.clrblack)),
//               Spacer(),
//               Radio<int>(
//                 value: 1,
//                 groupValue: _selectedIndex,
//                 activeColor: CustomColors.clrorange,
//                 onChanged: (int? value) {
//                   setState(() {
//                     _selectedIndex = value!;
//                   });
//                   widget.audioManager.setShuffleMode(ShuffleMode.playOnceAndClose);
//                 },
//               ),
//             ],
//           ),
//           SizedBox(height: screenWidth * 0.05),
//           Row(
//             children: [
//               Icon(Icons.loop,
//                   color: CustomColors.clrorange, size: screenWidth * 0.05),
//               SizedBox(width: screenWidth * 0.05),
//               Text('Play on Loop',
//                   style: TextStyle(
//                       fontSize: screenWidth * 0.04, color: CustomColors.clrblack)),
//               Spacer(),
//               Radio<int>(
//                 value: 2,
//                 groupValue: _selectedIndex,
//                 activeColor: CustomColors.clrorange,
//                 onChanged: (int? value) {
//                   setState(() {
//                     _selectedIndex = value!;
//                   });
//                   widget.audioManager.setShuffleMode(ShuffleMode.playOnLoop);
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }