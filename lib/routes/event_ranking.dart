import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedala_mi/models/event.dart';
import 'package:pedala_mi/models/loggedUser.dart';
import 'package:pedala_mi/models/team.dart';
import 'package:pedala_mi/services/mongodb_service.dart';
import 'package:pedala_mi/size_config.dart';

class EventRankingPage extends StatefulWidget {
  const EventRankingPage({Key? key, required Event event}) : event=event, super(key: key);
  final Event event;

  @override
  _EventRankingPageState createState() => _EventRankingPageState();
}

class _EventRankingPageState extends State<EventRankingPage> {

  late Event event;
  List<LoggedUser> topUsers=[];
  int userInCurrentEventPosition=-1;
  bool loadingRanking=true;
  List<Team?> rankingTeams=[];
  late Team actualUserTeam;
  bool actualUserTeamFound=false;
  List<String> sameTeamEventUsersIdRanking=[];
  double userPoints=0;
  int userInTeamPosition=-1;

  @override
  void initState() {
    loadRanking();
    super.initState();
  }

  loadRanking()async
  {
    event=widget.event;
    if(event.isIndividual())
      {
        userInCurrentEventPosition=-1;
        if(event.scoreboard!.length>0)
        {
          event.scoreboard!.sort((a,b)=>b.points.compareTo(a.points));
          for(int i=0;i<event.scoreboard!.length;i++)
          {
            if(event.scoreboard![i].userId==FirebaseAuth.instance.currentUser!.uid)
            {
              userInCurrentEventPosition=i;
            }
          }

          topUsers.add(new LoggedUser(event.scoreboard![0].userId,NetworkImage("url"),"","",null,null,null,null,null,null,null));
          if(event.scoreboard!.length>1)
          {
            topUsers.add(new LoggedUser(event.scoreboard![1].userId,NetworkImage("url"),"","",null,null,null,null,null,null,null));
            if(event.scoreboard!.length>2)
            {
              topUsers.add(new LoggedUser(event.scoreboard![2].userId,NetworkImage("url"),"","",null,null,null,null,null,null,null));
            }
          }
          WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
            for(int i=0;i<topUsers.length;i++)
            {
              topUsers[i]=await topUser(event.scoreboard![i].userId,topUsers[i]);
            }
            //loading = false;
            setState(() {
              loadingRanking=false;
            });
          });

        }
        else
        {
          setState(() {
            loadingRanking=false;
          });
        }
      }
    if(event.isTeam())
      {
          if(event.teamScoreboard!=null)
            {
              if(event.teamScoreboard!.length>=1)
                {
                  rankingTeams.add(await MongoDB.instance.getTeam(event.teamScoreboard![0].teamId));
                }
              if(event.teamScoreboard!.length>=2)
                {
                  rankingTeams.add(await MongoDB.instance.getTeam(event.teamScoreboard![1].teamId));
                }
              if(event.teamScoreboard!.length>2)
                {
                  rankingTeams.add(await MongoDB.instance.getTeam(event.teamScoreboard![2].teamId));
                }
              for(ScoreboardEntry usersEntry in event.scoreboard!)
                {
                  if(usersEntry.userId.contains(FirebaseAuth.instance.currentUser!.uid))
                    {
                      if(rankingTeams.length>0)
                        {
                          for(Team? t in rankingTeams)
                            {
                              if(t!.id==usersEntry.teamId)
                                {
                                  actualUserTeam=t;
                                  actualUserTeamFound=true;
                                }
                            }
                        }
                      if(!actualUserTeamFound)
                        {
                          actualUserTeam=(await MongoDB.instance.getTeam(usersEntry.teamId!))!;
                          actualUserTeamFound=true;
                        }
                      if(actualUserTeamFound)
                        {
                          for(int i=0;i<event.scoreboard!.length;i++)
                            {
                              if(event.scoreboard![i].teamId==usersEntry.teamId)
                                {
                                  sameTeamEventUsersIdRanking.add(event.scoreboard![i].userId);
                                  if(event.scoreboard![i].userId==FirebaseAuth.instance.currentUser!.uid)
                                    {
                                      userInCurrentEventPosition=i;
                                      userInTeamPosition=sameTeamEventUsersIdRanking.length;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        setState(() {
          loadingRanking=false;
        });
      }

  }

  Future<LoggedUser> topUser(String uid, LoggedUser user) async
  {
    await FirebaseFirestore.instance.collection("Users").where("userId",isEqualTo: uid).get().then((QuerySnapshot querySnapshot) async{
      if(querySnapshot.docs.isNotEmpty)
      user=new  LoggedUser(uid,NetworkImage(querySnapshot.docs[0].get("Image")),"",querySnapshot.docs[0].get("Username"),null,null,null,null,null,null,null);
    });
    return user;
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
                padding:
                EdgeInsets.only(top: 3 * SizeConfig.heightMultiplier!),
                child: Center(
                  child: Text(
                    event.name+" rankings",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 35, ),
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 15),
            child:
              Column(
                children: [
                  event.scoreboard!.length==0?Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height*.25,),
                      Text("Nobody attends this event", style: TextStyle(fontSize: 25,color: Colors.grey),),
                    ],
                  ):SizedBox(),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 1000),
                    child: loadingRanking?Column(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height*.25,),
                        CircularProgressIndicator(),
                      ],
                    ):
                    event.isIndividual()?displayIndividualPodium():event.isTeam()?displayTeamsRanking():SizedBox(),
                  ),

                ],
              ),),
          ],
        ),
      ),
    );
  }

  Widget displayIndividualPodium()
  {
    return Column(
      children: [
        event.scoreboard!.length>0?
        displayTopPlayer("🥇", 0):SizedBox(),
        event.scoreboard!.length>1?
        displayTopPlayer("🥈", 1):SizedBox(),
        event.scoreboard!.length>2?
        displayTopPlayer("🥉", 2):SizedBox(),
        Padding(padding: EdgeInsets.only(bottom: 15)),
        userInCurrentEventPosition!=-1?Column(
          children: [
            Text("Your score: "+event.scoreboard![userInCurrentEventPosition].points.toStringAsFixed(0)+(event.scoreboard![userInCurrentEventPosition].points.toStringAsFixed(0)=="1"?" point":" points"),style: TextStyle(fontSize: 25)),
            Text("Your position: "+(position(userInCurrentEventPosition+1)).toString(),style: TextStyle(fontSize: 25))
          ],
        ):SizedBox()
      ],
    );
  }

  Widget displayTopPlayer(String medal, int i)
  {
    return Padding(
      padding: EdgeInsets.only(top:5),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              topUsers[i].image==NetworkImage("url")?Container(height: 40,width: 40,):Container(
                height: 40,
                width: 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(topUsers[i].image.url,
                    fit: BoxFit.cover,
                    errorBuilder:(BuildContext context, Object object, StackTrace? stacktrace){
                      return Image.asset("lib/assets/app_icon.png");
                    },
                    loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null ?
                          loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes as num)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Text(medal, style: TextStyle(fontSize: 40),),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(topUsers[i].username,style: TextStyle(fontSize: 25),textAlign: TextAlign.end,),
                    Text(event.scoreboard![i].points.toStringAsFixed(0)+(event.scoreboard![i].points.toStringAsFixed(0)=="1"?" point":" points"),style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.end)
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget displayTeamsRanking()
  {
    return event.teamScoreboard!=null?Column(
      children: [
        event.teamScoreboard!.length==0?Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*.2),
          child: Text("No one has scored points", style: TextStyle(fontSize:18,color: Colors.black54),),
        ):
        Column(
          children: [
            event.teamScoreboard!.length>0?
            displayTopTeam("🥇", 0):SizedBox(),
            event.teamScoreboard!.length>1?
            displayTopTeam("🥈", 1):SizedBox(),
            event.teamScoreboard!.length>2?
            displayTopTeam("🥉", 2):SizedBox(),
            Padding(padding: EdgeInsets.only(bottom: 15)),
            userInCurrentEventPosition!=-1?Column(
              children: [
                Text("Your score: "+event.scoreboard![userInCurrentEventPosition].points.toStringAsFixed(0)+(event.scoreboard![userInCurrentEventPosition].points.toStringAsFixed(0)=="1"?" point":" points"),style: TextStyle(fontSize: 18)),
                Text("Your position in "+actualUserTeam.name+": "+(position(userInTeamPosition+0)).toString(),style: TextStyle(fontSize: 18))
              ],
            ):SizedBox()
          ],
        ),

      ],
    ):Padding(
      padding:  EdgeInsets.only(top: MediaQuery.of(context).size.height*.2),
      child: Text("No one joined this event", style: TextStyle(fontSize: 18,color: Colors.black54)),
    );
  }

  Widget displayTopTeam(String medal, int i)
  {
    return Padding(
      padding: EdgeInsets.only(top:5),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 80,
                width: 80,
                child: Image.asset("lib/assets/app_icon.png"),
              ),
              Text(medal, style: TextStyle(fontSize: 40),),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(rankingTeams[i]!.name,style: TextStyle(fontSize: 25),textAlign: TextAlign.end,),
                    Text(event.teamScoreboard![i].points.toStringAsFixed(0)+(event.teamScoreboard![i].points.toStringAsFixed(0)=="1"?" point":" points"),style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.end)
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String position(double i)
  {
    var j = i % 10,
        k = i % 100;
    if (j == 1 && k != 11) {
      return i.toStringAsFixed(0) + "st";
    }
    if (j == 2 && k != 12) {
      return i.toStringAsFixed(0) + "nd";
    }
    if (j == 3 && k != 13) {
      return i.toStringAsFixed(0) + "rd";
    }
    return i.toStringAsFixed(0) + "th";
  }


}
