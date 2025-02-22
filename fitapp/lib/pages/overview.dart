import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitapp/components/pagecomponents.dart';
import 'package:fitapp/firestore/auth_methods.dart';
import 'package:fitapp/util/emoticon_face.dart';
import 'package:fitapp/util/exercise_tile.dart';
import 'package:flutter/material.dart';
 import 'package:intl/intl.dart';
import 'package:fitapp/components/theme/color_lib.dart';
import 'package:provider/provider.dart';

class Overview extends StatefulWidget {
  const Overview({super.key});

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  AuthService authService = AuthService();
  User? user = FirebaseAuth.instance.currentUser;
  String name = "";

  @override
  void initState(){
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userID = user?.uid;
    Map<String, dynamic>? userData = await authService.getDataByUUID(userID!);
    setState(() {
      name = userData?['username'];
    });
    Provider.of<AuthNotifier>(context, listen: false).setLoggedIn(user != null);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthNotifier>(
        builder: (context, authNotifier, child) {
        return DefBackground(
          body: SafeArea(
            bottom: false,
            child: Column(
              children:[
                Padding(
                  padding: const EdgeInsets.only(left:25.0,right:25.0, top: 25.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (authNotifier.loggedIn) ? "Hi there $name!" : 'Hi there!',
                                style: TextStyle(
                                  color: context.theme.appColors.onSurface,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(DateFormat('EEEE, MMMM d').format(DateTime.now()),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: context.theme.appColors.onSurfaceVariant,
                                  )),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: context.theme.appColors.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Icon(Icons.notifications,
                              color: context.theme.appColors.onSurface,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height:25,
                      ),
                      Container(
                          decoration: BoxDecoration(
                            color: context.theme.appColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: context.theme.appColors.onSurface,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Search',
                                style: TextStyle(
                                  color: context.theme.appColors.onSurface,
                                ),
                              ),
                            ],
                          )
                      ),
                      const SizedBox(
                        height:25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'How are you feeling today?',
                            style: TextStyle(
                              color: context.theme.appColors.onSurface,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.more_horiz,
                            color: context.theme.appColors.onSurface,),
                        ],
                      ),

                      const SizedBox(
                        height:25,
                      ),

                      //faces
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          //bad
                          Column(
                            children: [
                              const EmoticonFace(
                                emoticonFace: '😔',
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                'Bad',
                                style: TextStyle(color: context.theme.appColors.onSurface),
                              ),
                            ],
                          ),
                          //fine
                          Column(
                            children: [
                              const EmoticonFace(
                                emoticonFace: '🙂',
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                'Fine',
                                style: TextStyle(color: context.theme.appColors.onSurface),
                              ),
                            ],
                          ),
                          //well
                          Column(
                            children: [
                              const EmoticonFace(
                                emoticonFace: '😁',
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                'Well',
                                style: TextStyle(color: context.theme.appColors.onSurface),
                              ),
                            ],
                          ),
                          //excellent
                          Column(
                            children: [
                              const EmoticonFace(
                                emoticonFace: '🥳',
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                'Excellent',
                                style: TextStyle(color: context.theme.appColors.onSurface),
                              ),
                            ],
                          ),
                        ],),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25.0,
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      height: 500,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.theme.appColors.secondaryContainer,
                            context.theme.appColors.tertiaryContainer,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          children:[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Exercises',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: context.theme.appColors.onSurface,
                                  ),
                                ),
                                const Icon(Icons.more_horiz),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),

                            //listview of exercises
                            Expanded(
                              child: ListView(
                                children: const [
                                  ExerciseTile(
                                    icon: Icons.favorite,
                                    exerciseName: 'Test 1',
                                    exerciseDesc: 'Test 2',
                                    color: Colors.red,
                                  ),
                                  ExerciseTile(
                                    icon: Icons.person,
                                    exerciseName: 'Test 3',
                                    exerciseDesc: 'Test 4',
                                    color: Colors.blue,
                                  ),
                                  ExerciseTile(
                                    icon: Icons.star,
                                    exerciseName: 'Test 5',
                                    exerciseDesc: 'Test 6',
                                    color: Colors.green,
                                  ),
                                  ExerciseTile(
                                    icon: Icons.star,
                                    exerciseName: 'Test 5',
                                    exerciseDesc: 'Test 6',
                                    color: Colors.green,
                                  ),
                                  ExerciseTile(
                                    icon: Icons.star,
                                    exerciseName: 'Test 5',
                                    exerciseDesc: 'Test 6',
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }
}