import 'package:flutter/material.dart';
import 'package:sangit/ui_helper/custom_colors.dart';
import 'package:html/parser.dart' as html_parser;

class Lyricsbhajan extends StatefulWidget {
  const Lyricsbhajan(this.musicLyrics, this.musicName, {super.key});

  final String musicLyrics;
  final String musicName;

  @override
  State<Lyricsbhajan> createState() => _LyricsbhajanState();
}

class _LyricsbhajanState extends State<Lyricsbhajan> {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    String parsedLyrics =
        html_parser.parse(widget.musicLyrics).body?.text ?? '';

    return Scaffold(
      backgroundColor: CustomColors.clrwhite,
      appBar: AppBar(
        backgroundColor: Colors.black12,
        shadowColor: CustomColors.clrblack,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: CustomColors.clrblack,
              size: screenWidth * 0.06,
            )),
        title: Text(
          "Lyrics of the song",
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: CustomColors.clrblack,
              fontSize: screenWidth * 0.05),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.ac_unit,
                      color: Colors.orange,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                      child: SizedBox(
                          width: screenWidth * 0.5,
                          child: Text(
                            widget.musicName,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: screenWidth * 0.06),
                          )),
                    ),
                    const Icon(
                      Icons.ac_unit,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
              Text(
                parsedLyrics,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    color: CustomColors.clrblack,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
