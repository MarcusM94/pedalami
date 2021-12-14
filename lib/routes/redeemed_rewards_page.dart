import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/models/reward.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:pedala_mi/widget/redeemed_reward_item.dart';

class RedeemedRewardsPage extends StatefulWidget {
  const RedeemedRewardsPage({Key? key}) : super(key: key);

  @override
  _RedeemedRewardsPageState createState() => _RedeemedRewardsPageState();
}

class _RedeemedRewardsPageState extends State<RedeemedRewardsPage> {

  late bool loading;
  List<RedeemedReward> redeemedRewards=[];


  @override
  void initState() {
    loading=true;
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      redeemedRewards=(await MongoDB.instance.getAllRewardsFromUser(FirebaseAuth.instance.currentUser!.uid))!;
      print(redeemedRewards.length);
      loading=false;
      setState(() {

      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Colors.green[600],
                height: 20 * SizeConfig.heightMultiplier!,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 3 * SizeConfig.heightMultiplier!),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Redeemed rewards", style: TextStyle(color: Colors.white, fontSize: 30),),
                    ],
                  ),
                ),
              ),
              loading?Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.width*.5,),
                  CircularProgressIndicator(color: Colors.green[600],),
                  SizedBox(height: MediaQuery.of(context).size.width*.05,),
                  Text("Loading...", style: TextStyle(fontSize: 17),)
                ],
              ):(redeemedRewards.length==0?Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.width*.6,),
                  Text("No redeemed rewards.", style: TextStyle(fontSize: 17, color: Colors.grey),)
                ],
              ):
              RedeemedRewardItem(rewards: redeemedRewards))
            ],
          ),
        )
    );
  }
}
