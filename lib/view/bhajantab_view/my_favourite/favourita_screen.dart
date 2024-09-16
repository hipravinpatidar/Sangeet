import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:sangit/controller/favourite_manager.dart';
import 'package:sangit/controller/share_music.dart';
import 'package:sangit/ui_helper/custom_colors.dart';
import 'dart:math' as math;
import '../../../controller/audio_manager.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({Key? key}):super(key: key);

  @override
  _FavouriteScreenState createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> with TickerProviderStateMixin {
  late AudioPlayer audioPlayer;

   late AudioPlayerManager audioManager;
   late FavoriteProvider favoriteProvider;

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
    final selectedMusic = favoriteProvider.favoriteList[index];
    audioManager.playMusic(selectedMusic).then((_) {
      setState(() {
        _isMusicBarVisible = true;
      });
    }).catchError((error) {
      print('Error playing music: $error');
    });
  }

  Widget _buildMusicList(List favoriteList) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: favoriteList.length,
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
      itemBuilder: (context, index) {

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
                      image: NetworkImage(favoriteList[index].image),
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
                          favoriteList[index].title,
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
                          favoriteList[index].singerName.toString(),
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
                      size: screenWidth * 0.07,
                    ),
                    onPressed: () {
                     // shareMusic.shareSong();
                    },
                  ),
                GestureDetector(
                 onTap: () => _showBottomSheet(favoriteList,index),
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

    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final favoriteList = favoriteProvider.favoriteList;

    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body : Consumer<FavoriteProvider>(
           builder: (BuildContext context, favouritemanager, Widget? child) {
           return Scaffold(
             backgroundColor: Color.fromRGBO(247, 247, 247, 1),

             appBar: AppBar(
               toolbarHeight: screenWidth * 0.2,
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
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(width:screenWidth * 0.7,
                                      child: Text(
                                        "Your Favourite's Here",
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
                            ),
                          ),
                        ],
                      ),
                    ),
                 ),
              ),
               body: Stack(
                children: [
                 _buildMusicList(favoriteList),
                 if (_isMusicBarVisible && audioManager.currentMusic != null)
                   Align(
                     alignment: Alignment.bottomCenter,
                     child: AnimatedContainer(
                       duration: Duration(milliseconds: 100),
                       //height: 72,
                       height: screenWidth * 0.2,
                       color: Colors.brown,
                       child: GestureDetector(
                         onTap: () {
                           //Navigator.push(context,
                            // MaterialPageRoute(builder: (context) => MusicPlayer(audioManager.currentIndex,widget.subCategoryModel,widget.godName)),
                          // );
                         },
                         child: FractionallySizedBox(
                           heightFactor: 1.0,
                           widthFactor: 1.0,
                           child: Padding(
                             padding: EdgeInsets.symmetric(
                               vertical: screenWidth* 0.02,
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
                                         audioManager.currentMusic!.image.toString(),
                                       ),
                                       fit: BoxFit.cover,
                                     ),
                                     borderRadius: BorderRadius.circular(10),
                                   ),
                                 ),
                                 Expanded(
                                   child: Padding(
                                     padding: EdgeInsets.only(top: screenWidth * 0.02, left: screenWidth * 0.02),
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         SizedBox(width: screenWidth * 0.5,
                                           child: Text(
                                             audioManager.currentMusic?.title.toString() ?? '',
                                             style: const TextStyle(
                                               color: Colors.white,
                                               overflow: TextOverflow.ellipsis,
                                             ),
                                             maxLines: 1,
                                           ),
                                         ),
                                         SizedBox(width: screenWidth * 0.5,
                                           child: Text(
                                             audioManager.currentMusic?.singerName.toString() ?? '',
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
                                   onPressed:
                                   audioManager.isPlaying ? audioManager.skipNext : _toggleMusicBarVisibility,
                                   icon: Icon(
                                     audioManager.isPlaying ? Icons.skip_next : Icons.highlight_remove_outlined,color: Colors.white,
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
      ),
    );
  }

  void _showShareBottomSheet() {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: CustomColors.clrwhite,
      builder: (BuildContext context) {
        return Container(
          height: 350,
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              children: <Widget>[
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
                const Divider(),
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
                                  "https://s3-alpha-sig.figma.com/img/7ffe/2ead/b9d4ea9adb840676bcecff2319aff2e2?Expires=1722816000&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=GQtQ6fo2QpdlpefDjjJ0u1kbC4YovRXQZ57DQagMJ-MpvXRQcNJm02jnpfx-2~jd1uf-9r-f2pqN1e~hbOhbWzGmQ4vWx0N9SjJy5TKJs7Ub5T7u45ez~cNJu~~of1fuNAfdlVg~KtzVuK~sOmKZNUFW~~A~0muyCaTnOnF50YDtgTA7jO1qDQE6t49WqYM9Oa1VWVcXkObnjrZ73-gI8L8E4RVMYmqvuOGdanjQb4MvUaZ-Z9fUGQbzEMqjtIeZulc5peS1Wxg8kvX6-~i-9PTsf6h12fr5ik7LZaU5Oh6AsxtvVYWa5PvYjA8eWG~B0ojG0UdC8qCJAdoL..."),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Text(
                          "WhatsApp",
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

  void _showBottomSheet(List MyFavlist,int myIndex) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;


    showModalBottomSheet(
      context: context,
      backgroundColor: CustomColors.clrwhite,
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Options",
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
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete, color: CustomColors.clrorange),
                  title: const Text('Remove from Favorites'),
                  onTap: () {
                    Provider.of<FavoriteProvider>(context, listen: false).removeFromFavorites(MyFavlist[myIndex]);
                    Navigator.pop(context);

                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share, color: CustomColors.clrorange),
                  title: const Text('Share'),
                  onTap: () {
                    // Handle share
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

