// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:sangit/api_service/api_services.dart';
// import 'package:sangit/model/all_category.dart';
// import 'package:sangit/ui_helper/custom_colors.dart';
// import '../../../model/all_category.dart';
//
// class AllBhajan extends StatefulWidget {
//   const AllBhajan({super.key, required this.categoryId});
//
//   final int categoryId;
//
//   @override
//   State<AllBhajan> createState() => _AllBhajanState();
// }
//
// class _AllBhajanState extends State<AllBhajan> {
//   @override
//   void initState() {
//     // getAllCategoryData();
//     super.initState();
//   }
//
//
//   List<AllCategoryModel> allcategorymodel = [];
//
//   Future<void> getAllCategoryData() async {
//     var res = await ApiService().getAllCategory(
//       "https://mahakal.rizrv.in/api/v1/sangeet/sangeet-all-details?category_id=${widget.categoryId}&language=hindi",
//     );
//
//     allcategorymodel.clear();
//     List categoryList = res;
//     allcategorymodel
//         .addAll(categoryList.map((e) => AllCategoryModel.fromJson(e)));
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       backgroundColor: CustomColors.clrwhite,
//       body: FutureBuilder(
//         future: getAllCategoryData(),
//         builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
//           return ListView.builder(
//             physics: NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             scrollDirection: Axis.vertical,
//             itemCount: allcategorymodel.length,
//             padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
//             itemBuilder: (context, index) {
//               final music = allcategorymodel[index];
//
//               return InkWell(
//                 //onTap: () => playMusic(index),
//                 // onTap: () => audioManager.playMusic(music),
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(
//                     vertical: screenWidth * 0.01,
//                     horizontal: screenWidth * 0.04,
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         height: screenHeight * 0.05,
//                         width: screenWidth * 0.1,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(6),
//                           image: DecorationImage(
//                             image: NetworkImage(allcategorymodel[index].image),
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.symmetric(
//                             horizontal: screenWidth * 0.03),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(
//                               width: screenWidth * 0.4,
//                               child: Text(
//                                 allcategorymodel[index].title,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: screenWidth * 0.04,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 maxLines: 1,
//                               ),
//                             ),
//                             SizedBox(
//                               width: screenWidth * 0.3,
//                               child: Text(
//                                 allcategorymodel[index].singerName,
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                   fontSize: screenWidth * 0.03,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 maxLines: 1,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Spacer(),
//                       GestureDetector(
//                         //onTap: _showShareBottomSheet,
//                         child: Container(
//                           height: screenWidth * 0.06,
//                           width: screenWidth * 0.06,
//                           decoration: BoxDecoration(
//                             image: DecorationImage(
//                               image: NetworkImage(
//                                 "https://s3-alpha-sig.figma.com/img/7ffe/2ead/b9d4ea9adb840676bcecff2319aff2e2?Expires=1724025600&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=Q2y8uNeaEkXmyllu9wK8meE7XRhaT4YYNXzO7N9-ztiY3hiZWOaOh64DMLJRFE53dkKcd9yJlxHPSdjZYSDFhI9JMzYS2O9Wo8ODuimUnFYzVlW~upNfNOD6ioMlkdph6oyZMFqdudz42sT8B63wo0M3o2fm00AummkrkoKQftQlbHCFuSfpdVGtkIuOfkoVdwCrjC20TvQhZ38mp1TW87mhNLa6ntBwrQZ1xPb~RvImeFFtsC-DWPDw-6SCn9nIFetXarRnMBC8udktSG7YmIyvH5r5BeBDgs8fLmgSdP4nTJFQiGP3M2KGxVbilRS5CjXIXowOz9GqYOZf1yDAuA__",
//                               ),
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Transform.rotate(
//                         angle: -45 * 1.14159 / 180,
//                         child: IconButton(
//                           icon: Icon(
//                             Icons.notifications_active_sharp,
//                             color: Colors.orange,
//                             size: screenWidth * 0.07,
//                           ),
//                           onPressed: () {
//                             // Handle notification icon tap
//                           },
//                         ),
//                       ),
//                       GestureDetector(
//                         // onTap: () => _showBottomSheet(index),
//                         child: Icon(
//                           Icons.more_vert_rounded,
//                           color: Colors.orange,
//                           size: screenWidth * 0.07,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
