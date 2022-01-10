import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/routes/team_members.dart';
import 'package:pedala_mi/routes/your_events_page.dart';
import 'package:pedala_mi/size_config.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:pedala_mi/models/team.dart';
import 'package:pedala_mi/services/mongodb_service.dart';

import 'create_team_event.dart';
import 'events_enroll.dart';


class TeamProfile extends StatefulWidget {
  TeamProfile ({ Key? key, required this.team }) : super(key: key);
  final Team team;

  @override
  _TeamProfileState createState() => _TeamProfileState();
}

class _TeamProfileState extends State<TeamProfile> {
  bool check = false;

  @override
  void initState() {
    widget.team.addListener(() => setState(() {}));
    super.initState();
  }

  String? getAdminUsername() {
    //return widget.team.getAdminName() ?? "Username of the admin not found";
    return widget.team.getAdminName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.green[600],
              height: 45 * SizeConfig.heightMultiplier!,
              width: 100 * SizeConfig.widthMultiplier!,
              child: Padding(
                padding: EdgeInsets.only(
                    left: 30.0,
                    right: 30.0,
                    top: 10 * SizeConfig.heightMultiplier!),
                child: Column(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          height: 22 * SizeConfig.heightMultiplier!,
                          width: 32 * SizeConfig.widthMultiplier!,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            image: DecorationImage(
                              image: AssetImage("lib/assets/app_icon.png")
                            )
                          ),
                        ),
                        Text(
                          widget.team.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            fontSize: 4 * SizeConfig.textMultiplier!,),
                        ),

                        SizedBox(
                          width: 5 * SizeConfig.widthMultiplier!,
                        ),
                        /*Divider(
                          color: Colors.black54,
                        ),*/
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0,-30),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30.0),
                      topLeft: Radius.circular(30.0),
                    )),
                //child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(left: 30.0, top: 4 * SizeConfig.heightMultiplier!, right: 30.0,),
                  child: Column(
                    children: <Widget> [
                      Text( "Description",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          fontSize: 2.5 * SizeConfig.textMultiplier!,),
                      ),
                      Text( widget.team.description ?? "This team has no description",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black54,
                          fontSize: 2 * SizeConfig.textMultiplier!,),
                      ),
                      Divider(
                        color: Colors.black54,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 3 * SizeConfig.heightMultiplier!),),
                      Text( "Team Admin",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          fontSize: 2.5 * SizeConfig.textMultiplier!,),
                      ),
                      AnimatedSwitcher(duration: Duration(milliseconds: 250),
                      child: getAdminUsername()!=null?Text(
                        getAdminUsername()!,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black54,
                          fontSize: 2.3 * SizeConfig.textMultiplier!,),
                      ):Container(
                        height: 2.3 * SizeConfig.textMultiplier!,
                        width: 2.3 * SizeConfig.textMultiplier!,
                        child: CircularProgressIndicator(
                        ),
                      )),

                      Padding(
                        padding: EdgeInsets.only(
                            top: 3 * SizeConfig.heightMultiplier!,
                            ),
                        child: ElevatedButton(
                          onPressed: () {
                            pushNewScreen(
                              context,
                              screen: TeamMembers(team: widget.team),
                              pageTransitionAnimation: PageTransitionAnimation.cupertino,
                            );
                          },
                          child: Text("Team Members"),
                          style: ButtonStyle(
                              fixedSize: MaterialStateProperty.all(
                                  Size(200, 35)),
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.lightGreen),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(
                                          color: Colors.lightGreen)))),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 3 * SizeConfig.heightMultiplier!,),
                        child: ElevatedButton(
                          onPressed: () async{
                            var response = await MongoDB.instance.leaveTeam(widget.team.id, LoggedUser.instance!.userId);
                            if(response.item1)
                            {
                              LoggedUser.instance!.teams?.remove(widget.team);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                  widget.team.name+" left successfully!",),
                              ));
                              LoggedUser.instance!.notifyListeners();
                            }
                            else
                            {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                  response.item2,),
                              ));
                            }
                            Navigator.of(context).pop();
                          },
                          child: Text("Leave team", style: TextStyle(color: Colors.grey[800]),),
                          style: ButtonStyle(
                              fixedSize: MaterialStateProperty.all(
                                  Size(200, 35)),
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.redAccent),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(
                                          color: Colors.redAccent)))),
                        ),
                      ),
                      getAdminUsername()==LoggedUser.instance!.username?(
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: 3 * SizeConfig.heightMultiplier!,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                pushNewScreen(
                                  context,
                                  screen: EnrollEvent(actualTeam: widget.team,),
                                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                );
                              },
                              child: Text("Enroll to event"),
                              style: ButtonStyle(
                                  fixedSize: MaterialStateProperty.all(
                                      Size(200, 35)),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.lightGreen),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18.0),
                                          side: BorderSide(
                                              color: Colors.lightGreen)))),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 3 * SizeConfig.heightMultiplier!,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                pushNewScreen(
                                  context,
                                  screen: YourEventsPage(activeTeam: widget.team,),
                                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                );
                              },
                              child: Text("Your events"),
                              style: ButtonStyle(
                                  fixedSize: MaterialStateProperty.all(
                                      Size(200, 35)),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.lightGreen),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18.0),
                                          side: BorderSide(
                                              color: Colors.lightGreen)))),
                            ),
                          ),Padding(
                            padding: EdgeInsets.only(
                              top: 3 * SizeConfig.heightMultiplier!,
                              bottom: 3 * SizeConfig.heightMultiplier!,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                pushNewScreen(
                                  context,
                                  screen: CreateTeamEvent(actualTeam: widget.team,),
                                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                );
                              },
                              child: Text("Create event"),
                              style: ButtonStyle(
                                  fixedSize: MaterialStateProperty.all(
                                      Size(200, 35)),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.lightGreen),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18.0),
                                          side: BorderSide(
                                              color: Colors.lightGreen)))),
                            ),
                          ),


                        ],

                      )
                      ):Container()
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }

  String nStringToNNString(String? str) {
    return str ?? "";
  }

/*void checkValue() async {
    setState(() {
      check = true;
    });
    await updateUsername(usernameController.text, context, _miUser);
    setState(() {
      check = false;
    });
  }*/

}