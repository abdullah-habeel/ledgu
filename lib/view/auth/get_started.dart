import 'package:flutter/material.dart';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/utilties/images.dart';
import 'package:ledgu/widgets/button.dart';
import 'package:ledgu/widgets/gapbox.dart';
import 'package:ledgu/widgets/text.dart';

import 'login.dart';
import 'signup.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.black1,
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              GapBox(68),
              Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 75,
                  backgroundImage: AssetImage(MyImages.image),
                ),
              ),
              GapBox(10),
              MyText(
                text: 'Mobile POS',
                fontWeight: FontWeight.w600,
                color: AppColors.grey1,
                fontSize: 18,
              ),
              GapBox(10),
              MyText(
                text:
                    'Help you manage your inventory in\n offline App. Help you manage your.',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.grey1,
                textAlign: TextAlign.center,
              ),
              GapBox(10),

              MyButton(
                text: 'Create & Register Store',
                backgroundColor: Colors.transparent,
                borderColor: Colors.white,
                foregroundColor: AppColors.grey1,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Signup()),
                  );
                },
              ),
              GapBox(10),

              MyButton(
                text: 'Signin using Google Account',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Login()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:ledgu/utilties/colors.dart';
// import 'package:ledgu/utilties/images.dart';
// import 'package:ledgu/widgets/button.dart';
// import 'package:ledgu/widgets/gapbox.dart';
// import 'package:ledgu/widgets/text.dart';

// class GetStarted extends StatelessWidget {
//   const GetStarted({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: AppColors.black1,
//         body: Padding(
//           padding: const EdgeInsets.all(15.0),
//           child: Column(
//             children: [
//               GapBox(68),
//               Align(
//                 alignment: Alignment.center,
//                 child: CircleAvatar(
//                   radius: 75,
//                   backgroundImage: AssetImage(MyImages.image),
//                 ),
//               ),
//               GapBox(10),
//               MyText(
//                 text: 'Mobile POS',
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.grey1,
//                 fontSize: 18,
//               ),
//               GapBox(10),
//               MyText(
//                 text:
//                     'Help you manage your inventory in\n offline App. Help you manage your.',
//                 fontSize: 12,
//                 fontWeight: FontWeight.w400,
//                 color: AppColors.grey1,
//               ),
//               GapBox(10),
//               MyButton(
//                 text: 'Create & Register Store',
//                 backgroundColor: Colors.transparent,
//                 borderColor: Colors.white,
//                 foregroundColor: AppColors.grey1,
//                 onPressed: () {},
//               ),
//               GapBox(10),
//               MyButton(text: 'Signin using Google Account', onPressed: () {}),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
