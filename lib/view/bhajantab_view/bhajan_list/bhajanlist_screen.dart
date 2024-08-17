import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sangit/controller/language_manager.dart';
import 'package:sangit/model/sangeet_model.dart';
import 'package:sangit/view/bhajantab_view/lyrics/lyricsbhajan.dart';
import 'package:sangit/view/scrollingeffect.dart';
import '../../../api_service/api_services.dart';
import '../../../controller/audio_manager.dart';
import '../../../controller/favourite_manager.dart';
import '../../../ui_helper/custom_colors.dart';

class BhajanList extends StatefulWidget {
  BhajanList(this.subCategoryId, this.subCategoryModel, this.godName,
      {super.key,
      required this.categoryId,
      required this.isToggle,
      required this.isFixedTab,
      required this.isAllTab,
      required this.isMusicBarVisible});

  int subCategoryId;
  final List subCategoryModel;
  final String godName;
  final int categoryId;
  final bool isToggle;
  final bool isAllTab;
  final bool isFixedTab;
  final bool isMusicBarVisible;

  @override
  State<BhajanList> createState() => _BhajanListState();
}

class _BhajanListState extends State<BhajanList> {
  late AudioPlayerManager audioManager;
  late bool _isMusicBarVisible;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMusicData();
    getAllCategoryData();
    _isMusicBarVisible = widget.isMusicBarVisible;
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Call your method to fetch data again or refresh the content
    [fetchMusicData(), getAllCategoryData()];

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    audioManager = Provider.of<AudioPlayerManager>(context);
  }

  List<Sangeet> musiclistdata = [];
  Future<void> fetchMusicData() async {
    String currentLanguage = context.read<LanguageManager>().nameLanguage;

    try {
      final musicListResponse = await ApiService().fetchSangeetData(
        'https://mahakal.rizrv.in/api/v1/sangeet/sangeet-details?subcategory_id=${widget.subCategoryId}&language=$currentLanguage',
      );

      //  print(" My Coming Language is ${languageManager.nameLanguage}");
      if (musicListResponse != null) {
        final sangeetModel = SangeetModel.fromJson(musicListResponse);

        setState(() {
          musiclistdata.clear();
          musiclistdata = sangeetModel.sangeet;
          audioManager.setPlaylist(musiclistdata);
          _isLoading = false;
        });
      } else {
        print("Error: The response is null or improperly formatted.");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print("Failed to fetch music data: $error");
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Sangeet> allcategorymodel = [];
  Future<void> getAllCategoryData() async {
    String currentLanguage = context.read<LanguageManager>().nameLanguage;

    var res = await ApiService().getAllCategory(
      "https://mahakal.rizrv.in/api/v1/sangeet/sangeet-all-details?category_id=${widget.categoryId}&language=$currentLanguage",
    );

    allcategorymodel.clear();
    List categoryList = res;
    allcategorymodel.addAll(categoryList.map((e) => Sangeet.fromJson(e)));
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
                Container(
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
                GestureDetector(
                  onTap: _showShareBottomSheet,
                  child: Container(
                    height: screenWidth * 0.06,
                    width: screenWidth * 0.06,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          "https://s3-alpha-sig.figma.com/img/7ffe/2ead/b9d4ea9adb840676bcecff2319aff2e2?Expires=1724025600&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=Q2y8uNeaEkXmyllu9wK8meE7XRhaT4YYNXzO7N9-ztiY3hiZWOaOh64DMLJRFE53dkKcd9yJlxHPSdjZYSDFhI9JMzYS2O9Wo8ODuimUnFYzVlW~upNfNOD6ioMlkdph6oyZMFqdudz42sT8B63wo0M3o2fm00AummkrkoKQftQlbHCFuSfpdVGtkIuOfkoVdwCrjC20TvQhZ38mp1TW87mhNLa6ntBwrQZ1xPb~RvImeFFtsC-DWPDw-6SCn9nIFetXarRnMBC8udktSG7YmIyvH5r5BeBDgs8fLmgSdP4nTJFQiGP3M2KGxVbilRS5CjXIXowOz9GqYOZf1yDAuA__",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: -45 * 1.14159 / 180,
                  child: IconButton(
                    icon: Icon(
                      Icons.notifications_active_sharp,
                      color: Colors.orange,
                      size: screenWidth * 0.07,
                    ),
                    onPressed: () {
                      // Handle notification icon tap
                    },
                  ),
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
                  ? const Center(child: CircularProgressIndicator())
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
                    height: screenWidth * 0.2,
                    color: Colors.brown,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation,
                                    secondaryAnimation) =>
                                MusicPlayer(
                                    MyCurrentIndex: audioManager.currentIndex,
                                    subCategoryModel: widget.subCategoryModel,
                                    godName: widget.godName,
                                    musiclistdata,
                                    widget.categoryId,
                                    widget.subCategoryId),
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
                        heightFactor: 1.0,
                        widthFactor: 1.0,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: screenWidth * 0.02,
                            horizontal: screenWidth * 0.04,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: screenWidth * 0.1,
                                height: screenWidth * 0.1,
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
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                      SizedBox(
                                        width: screenWidth * 0.5,
                                        child: Text(
                                          audioManager.currentMusic?.singerName
                                                  .toString() ??
                                              '',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  audioManager.togglePlayPause();
                                },
                                icon: Icon(
                                  audioManager.isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                  color: Colors.white,
                                  size: screenWidth * 0.1,
                                ),
                              ),
                              IconButton(
                                onPressed: audioManager.isPlaying
                                    ? audioManager.skipNext
                                    : _toggleMusicBarVisibility,
                                icon: Icon(
                                  audioManager.isPlaying
                                      ? Icons.skip_next
                                      : Icons.highlight_remove_outlined,
                                  color: Colors.white,
                                  size: screenWidth * 0.1,
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
                        Icons.dangerous,
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
                    Provider.of<FavoriteProvider>(context, listen: false)
                        .addToFavorites(musiclistdata[index]);
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
                              musiclistdata[index].lyrics,
                              musiclistdata[index].title),
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

  void _showShareBottomSheet() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: CustomColors.clrwhite,
      builder: (BuildContext context) {
        return Container(
          height: 350,
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Share this Song",
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: CustomColors.clrblack,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.dangerous,
                        size: screenWidth * 0.06,
                        color: CustomColors.clrblack,
                      ),
                    ),
                  ],
                ),
                Divider(),
                GridView.builder(
                  itemCount: 8,
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        Container(
                          height: screenWidth * 0.1,
                          width: screenWidth * 0.1,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(
                                "https://s3-alpha-sig.figma.com/img/7ffe/2ead/b9d4ea9adb840676bcecff2319aff2e2?Expires=1722816000&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=GQtQ6fo2QpdlpefDjjJ0u1kbC4YovRXQZ57DQagMJ-MpvXRQcNJm02jnpfx-2~jd1uf-9r-f2pqN1e~hbOhbWzGmQ4vWx0N9SjJy5TKJs7Ub5T7u45ez~cNJu~~of1fuNAfdlVg~KtzVuK~sOmKZNUFW~~A~0muyCaTnOnF50YDtgTA7jO1qDQE6t49WqYM9Oa1VWVcXkObnjrZ73-gI8L8E4RVMYmqvuOGdanjQb4MvUaZ-Z9fUGQbzEMqjtIeZulc5peS1Wxg8kvX6-~i-9PTsf6h12fr5ik7LZaU5Oh6AsxtvVYWa5PvYjA8eWG~B0ojG0UdC8qCJAdoLoC2oDg__",
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Text(
                          "Watsapp",
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: CustomColors.clrblack,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
