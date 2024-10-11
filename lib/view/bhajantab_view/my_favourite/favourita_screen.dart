import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:sangit/controller/favourite_manager.dart';
import 'package:sangit/controller/language_manager.dart';
import 'package:sangit/controller/share_music.dart';
import 'package:sangit/ui_helper/custom_colors.dart';
import 'package:sangit/view/sangeet_home/sangit_home.dart';
import 'dart:math' as math;
import '../../../controller/audio_manager.dart';
import '../lyrics/lyricsbhajan.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({Key? key}):super(key: key);

  @override
  _FavouriteScreenState createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> with TickerProviderStateMixin {
  late AudioPlayer audioPlayer;

   late AudioPlayerManager audioManager;
   late FavouriteProvider favouriteProvider;

   final shareMusic = ShareMusic();

   bool _isMusicBarVisible = true;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    audioManager = Provider.of<AudioPlayerManager>(context);
    favouriteProvider = Provider.of<FavouriteProvider>(context);
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void _toggleMusicBarVisibility() {
    setState(() {
      _isMusicBarVisible = !_isMusicBarVisible;
    });
  }

  void playMusic(int index) {
    print(" mY index is that ${index}");
    final selectedMusic = favouriteProvider.favouriteBhajan[index];
    audioManager.playMusic(selectedMusic).then((_) {
      setState(() {
        _isMusicBarVisible = true;
      });
    }).catchError((error) {
      print('Error playing music: $error');
    });
  }

  Widget _buildMusicList() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<FavouriteProvider>(
      builder: (BuildContext context, favouriteProvider , Widget? child) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount:  favouriteProvider.favouriteBhajan.length,
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
          itemBuilder: (context, index) {

            final bhajan = favouriteProvider.favouriteBhajan[index];

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
                          image: NetworkImage(bhajan.image),
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
                              bhajan.title,
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
                              bhajan.singerName.toString(),
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
                        Icons.offline_share,
                        color: Colors.orange,
                        size: screenWidth * 0.06,
                      ),
                      onPressed: () {
                         shareMusic.shareSong(favouriteProvider.favouriteBhajan[index]);
                      },
                    ),
                    GestureDetector(
                      onTap: () => _showBottomSheet(favouriteProvider.favouriteBhajan,index),
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
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body : Consumer<FavouriteProvider>(
           builder: (BuildContext context, favouriteBhajan, Widget? child) {
           return Scaffold(
             backgroundColor: Color.fromRGBO(247, 247, 247, 1),

             appBar: AppBar(
               toolbarHeight: screenWidth * 0.2,
               automaticallyImplyLeading: false,
               flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(""),
                          fit: BoxFit.cover,
                        ),
                        color: Colors.blue,
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04),
                            child: Consumer<LanguageManager>(
                              builder: (BuildContext context, languageManager, Widget? child) {
                                return Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      children: [
                                        SizedBox(width:screenWidth * 0.7,
                                          child: Text(
                                            languageManager.selectedLanguage == 'English' ? "Your Favourite's Here" : "आपका पसंदीदा यहाँ है",
                                            style: TextStyle(
                                                fontSize: screenWidth * 0.04,
                                                color: CustomColors.clrwhite,
                                                fontWeight: FontWeight.w500,
                                                overflow: TextOverflow.ellipsis),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
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
                                    SizedBox(width: screenWidth * 0.05)
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                 ),
              ),
               body: favouriteBhajan.favouriteBhajan.isEmpty ? Column(
                 children: [

                   SizedBox(height: screenWidth * 0.2,),
                   Padding(
                     padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                     child: Container(
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(10),
                         border: Border.all(color: Colors.grey),
                       ),
                       child: Padding(
                         padding: EdgeInsets.symmetric(vertical: screenWidth * 0.05,),
                         child: Consumer<LanguageManager>(
                           builder: (BuildContext context, languageManager, Widget? child) {
                             return  Column(
                               children: [

                                 SizedBox(height: screenWidth * 0.03,),
                                 Container(
                                   height: 100,
                                   width: 100,
                                   decoration: const BoxDecoration(
                                       image: DecorationImage(image: AssetImage("assets/image/favourite.png"))
                                   ),
                                 ),

                                 SizedBox(height: screenWidth * 0.02,),
                                 Padding(
                                   padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.14),
                                   child: Text(
                                     languageManager.selectedLanguage == 'English' ? "You haven't liked any music yet!" : "आपने अभी तक कोई संगीत पसंद नहीं किया है!",
                                     textAlign: TextAlign.center,style: TextStyle(fontSize: screenWidth * 0.04,color: Colors.black,fontWeight: FontWeight.bold),),
                                 ),

                                 SizedBox(height: screenWidth * 0.05,),
                                 Padding(
                                   padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                                   child: Text(
                                     languageManager.selectedLanguage == 'English' ? "Please go to the music collection and list your favorite music!" : "कृपाया संगीत संग्रह में जाए और अपने पसंदीदा संगीत की सूची बनाएं!",
                                     textAlign: TextAlign.center,style: TextStyle(fontSize: screenWidth * 0.04,color: Colors.black.withOpacity(0.5),),),
                                 ),

                                 SizedBox(height: screenWidth * 0.02,),

                                 Padding(
                                   padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.2),
                                   child: GestureDetector(
                                     onTap: () {
                                       Navigator.push(context, MaterialPageRoute(builder: (context) => SangitHome(myLanguage: ""),));
                                     },
                                     child: Container(
                                       decoration: BoxDecoration(
                                           borderRadius: BorderRadius.circular(20),
                                           border: Border.all(color: Colors.grey)
                                       ),
                                       child: Padding(
                                         padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02,horizontal: screenWidth * 0.03),
                                         child: Consumer<LanguageManager>(
                                           builder: (BuildContext context, languageManager, Widget? child) {
                                             return Row(
                                               children: [

                                                 const Icon(Icons.add_box_outlined,color: CupertinoColors.activeBlue,),
                                                 SizedBox(width: screenWidth * 0.03,),
                                                 Text(
                                                     languageManager.selectedLanguage == 'English' ? "like Music" : "संगीत पसंद करे"
                                                     ,style: const TextStyle(fontWeight: FontWeight.bold,color: CupertinoColors.activeBlue))
                                               ],
                                             );
                                           },
                                         ),
                                       ),
                                     ),
                                   ),
                                 )
                               ],
                             );
                           },
                         ),
                       ),
                     ),
                   )

                 ],
               ) :
               Stack(
                children: [
                 _buildMusicList(),
                 if (_isMusicBarVisible && audioManager.currentMusic != null)

                   Align(
                     alignment: Alignment.bottomCenter,
                     child: AnimatedContainer(
                       duration: const Duration(milliseconds: 100),
                       height: screenWidth * 0.19,
                       color: Colors.brown,
                       child: GestureDetector(
                         onTap: () {

                           // Navigator.push(
                           //   context,
                           //   PageRouteBuilder(
                           //     pageBuilder: (context, animation,
                           //         secondaryAnimation) =>
                           //
                           //         MusicPlayer(widget.godNameHindi,musicData: musiclistdata, categoryId: widget.categoryId, subCategoryId: widget.subCategoryId, allcategorymodel: allcategorymodel, MyCurrentIndex: audioManager.currentIndex, subCategoryModel: widget.subCategoryModel, godName: widget.godName),
                           //     transitionsBuilder: (context, animation,
                           //         secondaryAnimation, child) {
                           //       const begin = Offset(0.0, 1.0);
                           //       const end = Offset.zero;
                           //       const curve = Curves.easeInOutCirc;
                           //
                           //       var tween = Tween(begin: begin, end: end)
                           //           .chain(CurveTween(curve: curve));
                           //
                           //       return SlideTransition(
                           //         position: animation.drive(tween),
                           //         child: child,
                           //       );
                           //     },
                           //     transitionDuration: const Duration(
                           //         milliseconds: 1000), // Slow animation speed
                           //   ),
                           // );

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
                                     Row(
                                       children: [
                                         // Skip Previous Button
                                         IconButton(
                                           onPressed: () {

                                             if (audioManager.isPlaying) {
                                               int currentIndex = favouriteProvider.favouriteBhajan.indexOf(audioManager.currentMusic!);
                                               if (currentIndex > 0) {
                                                 playMusic(currentIndex - 1);
                                               } else {
                                                 playMusic(favouriteProvider.favouriteBhajan.length -
                                                     1); // Loop back to the last song
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
                                               int currentIndex = favouriteProvider.favouriteBhajan.indexOf(audioManager.currentMusic!);
                                               if (currentIndex <
                                                   favouriteProvider.favouriteBhajan.length - 1) {
                                                 playMusic(currentIndex + 1);
                                               } else {
                                                 playMusic(0); // Loop back to the first song
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
                                   ],
                                 ),

                                 Padding(
                                   padding:EdgeInsets.symmetric(vertical: screenWidth * 0.01),
                                   child: SizedBox(
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
      ),
    );
  }

  void _showBottomSheet(List MyFavlist,int index) {

    if (index < 0 || index >= MyFavlist.length) {
      print("Invalid index: $index");
      return;
    }


    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: CustomColors.clrwhite,
      builder: (BuildContext context) {
        return Consumer<AudioPlayerManager>(
          builder: (BuildContext context, audioManager, Widget? child) {
            return  SizedBox(
              height: 200,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Consumer<FavouriteProvider>(
                    builder: (BuildContext context, favouriteProvider, Widget? child) {

                      if (favouriteProvider.favouriteBhajan.length <= index) {
                        print("Invalid index: $index");
                        return const Center(child: Text("Invalid index"));
                      }

                      final isFavourite = favouriteProvider.favouriteBhajan.any((favourite) => favourite!.audio == MyFavlist[index].audio);

                        return Consumer<LanguageManager>(
                          builder: (BuildContext context, languageManager, Widget? child) {
                            return Consumer<FavouriteProvider>(
                              builder: (BuildContext context, favouriteProvider, Widget? child) {
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
                                              image: NetworkImage(favouriteProvider.favouriteBhajan[index].image),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                          EdgeInsets.symmetric(
                                              horizontal: screenWidth * 0.03),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: screenWidth * 0.4,
                                                child: Text(
                                                  favouriteProvider.favouriteBhajan[index]
                                                      .title,
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
                                                  favouriteProvider.favouriteBhajan[index]
                                                      .singerName,
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

                                    GestureDetector(
                                      onTap: () {
                                        favouriteProvider.toggleBookmark(MyFavlist[index]);
                                        Navigator.pop(context);
                                        print("Remove from Favourite");
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            isFavourite ? Icons.favorite : Icons
                                                .favorite_border_sharp,
                                            size: screenWidth * 0.06,
                                            color: CustomColors.clrorange,
                                          ),
                                          SizedBox(width: screenWidth * 0.04),
                                          Text(
                                            isFavourite
                                                ?   languageManager.selectedLanguage == 'English' ? "Remove from Favourite"
                                                : "पसंदीदा से हटाएँ" : "पसंदीदा से हटाएँ",
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
                                            musicLyrics: favouriteProvider.favouriteBhajan[index].lyrics,
                                            musicName: favouriteProvider.favouriteBhajan[index].title
                                        )));
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
                                            languageManager.selectedLanguage == 'English' ?
                                            "View Lyrics of the Music" : "संगीत के बोल देखें",
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
                        );
                      }
                    ),
              ),
            );
          },
        );
      },
    );
  }
}



