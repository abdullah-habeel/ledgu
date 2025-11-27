import 'package:flutter/material.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/utilties/images.dart';
import 'package:ledgu/widgets/text.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.black1,
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage(MyImages.image),
                ),
              ),
            ),
            const SizedBox(height: 20),
            MyText(text: 'Provided by Ledgu',color: AppColors.grey1,fontSize: 14,fontWeight: FontWeight.w500,),
            const SizedBox(height: 40), 
          ],
        ),
      ),
    );
  }
}
