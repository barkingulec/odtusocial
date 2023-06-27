// // import 'dart:html';

// // import 'package:rxdart/rxdart.dart';

// import 'dart:math';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// class NotificationService {
//   static final NotificationService _notificationService = 
//   NotificationService._internal();

//  factory NotificationService() {
//   return _notificationService;
//  }

//  NotificationService._internal(); 
 
//  AndroidNotificationChannel channel = const AndroidNotificationChannel(
// 'high_importance_channel', // id
// 'High Importance Notifications', // title
// description: 'This channel is used for important notifications.',
// playSound: true,
// // description
// importance: Importance.high,);

// final BehaviorSubject<String?> selectNotificationSubject = 
// BehaviorSubject<String?>();

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
// FlutterLocalNotificationsPlugin();

// Future<void> init() async {
// _configureSelectNotificationSubject();
// const AndroidInitializationSettings initializationSettingsAndroid =
// AndroidInitializationSettings('@mipmap/logo');
// DarwinInitializationSettings initializationSettingsDarwin =
// DarwinInitializationSettings(
//   requestSoundPermission: true,
//   requestBadgePermission: true,
//   requestAlertPermission: true,
//   onDidReceiveLocalNotification: onDidReceiveLocalNotification,
// );
// InitializationSettings initializationSettings = InitializationSettings(
//   android: initializationSettingsAndroid,
//   iOS: initializationSettingsDarwin,
//   macOS: null,
// );

// await flutterLocalNotificationsPlugin.initialize(
//   initializationSettings,
//   onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
//     if (notificationResponse.notificationResponseType ==
//         NotificationResponseType.selectedNotification) {
//       selectNotificationSubject.add(notificationResponse.payload);
//     }
//   },
// );

// await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//     onDidReceiveNotificationResponse: onSelectNotification,);

// await flutterLocalNotificationsPlugin
//     .resolvePlatformSpecificImplementation<
//     AndroidFlutterLocalNotificationsPlugin>()
//     ?.createNotificationChannel(channel);

// await flutterLocalNotificationsPlugin
//     .resolvePlatformSpecificImplementation<
//     IOSFlutterLocalNotificationsPlugin>()
//     ?.requestPermissions(
//   alert: true,
//   badge: true,
//   sound: true,
// );

// await FirebaseMessaging.instance
//     .setForegroundNotificationPresentationOptions(
//   alert: true,
//   badge: true,
//   sound: true,
// );

// initFirebaseListeners();}

// void _configureSelectNotificationSubject() {
// selectNotificationSubject.stream.listen((String? payload) async {
//   if (SharedPreferenceHelper().getUserToken() == null) {
//     return;
//   }
//   NotificationEntity? entity =
//   SharedPreferenceHelper().convertStringToNotificationEntity(payload);
//   debugPrint(
//       "notification _configureSelectNotificationSubject ${entity
//           .toString()}");
//   if (entity != null) {
//     setRedirectionFromForeground
//   }
// });}

// Future? onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) {
// if (SharedPreferenceHelper().getUserToken() == null) {
//   return null;
// }
// NotificationEntity? entity =
// SharedPreferenceHelper().convertStringToNotificationEntity(payload);
// debugPrint(
//     "notification onDidReceiveLocalNotification ${entity.toString()}");
// if (entity != null) {
//  setRedirectionFromForeground
// }
// return null;}
// void initFirebaseListeners() {
// FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//   if (SharedPreferenceHelper().getUserToken() == null) {
//     debugPrint("userToken is Null");
//     return;
//   }

//   debugPrint("OnMessageOpened notification opened ${message.data}");
//   NotificationEntity notificationEntity =
//   NotificationEntity.fromJson(message.data);
//   setRedirectionFromForeground
// });
// FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//   if (GetPlatform.isIOS ||
//       SharedPreferenceHelper().getUserToken() == null) {

//     return;
//   }
//   debugPrint("Foreground notification received  ${message.data}");
//   NotificationEntity notificationEntity =
//   NotificationEntity.fromJson(message.data);

//   debugPrint(message.data.toString());
//   notificationEntity.title = "App Name";
//   notificationEntity.body = notificationEntity.body;
//   showNotifications(notificationEntity);
// });}

// Future? onSelectNotification(NotificationResponse notificationResponse) {
// if (SharedPreferenceHelper().getUserToken() == null) {
//   return null;
// }
// NotificationEntity? entity =
// SharedPreferenceHelper().convertStringToNotificationEntity(notificationResponse.payload);
// debugPrint("notification onSelectNotification ${entity.toString()}");
// if (entity != null) {
//   setRedirectionFromForeground
// }
// return null;
// }

// Future<void> showNotifications(NotificationEntity notificationEntity) async {
// Random random = Random();
// int id = random.nextInt(900) + 10;
// await flutterLocalNotificationsPlugin.show(
//     id,
//     notificationEntity.title,
//     notificationEntity.body,
//     NotificationDetails(
//       android: AndroidNotificationDetails(
//         channel.id,
//         channel.name,
//         channelDescription: channel.description,
//         icon: "@mipmap/logo",
//         channelShowBadge: true,
//         playSound: true,
//         priority: Priority.high,
//         importance: Importance.high,
//         styleInformation: BigTextStyleInformation(notificationEntity.body!),
//       ),

//       iOS: DarwinNotificationDetails(
//         presentBadge: true,
//         presentSound: true,
//         presentAlert: true,
//         badgeNumber: 1,
//       )

//     ),
//     payload: SharedPreferenceHelper()
//         .convertNotificationEntityToString(notificationEntity));}
//  void pushNextScreenFromForeground(NotificationEntity notificationEntity) async {
// SharedPreferenceHelper preferenceHelper = SharedPreferenceHelper();
// Utils.showLoader();
// Tuple2<String, Object>? tuple2 = await callApi(notificationEntity);
// await Utils.hideLoader();
// debugPrint("current active screen ${Get.currentRoute}");
// if (tuple2 != null) {
//    //Set Redirection
//   }
//   Get.toNamed(tuple2.item1, arguments: tuple2.item2);
// }}}





// // class NotificationHelper { 
// //   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// //   var initializationSettings = InitializationSettings(android: AndroidInitializationSettings('app_logo'));
// //   final BehaviorSubject<ReceivedNotification>
// //       didReceivedLocalNotificationSubject =
// //       BehaviorSubject<ReceivedNotification>();
// //   var notificationSettings;
// //   init() async {
// //     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// //   }

// // Future<void> showNotification() async {
// //     var androidChannelSpecifics = AndroidNotificationDetails(
// //       'CHANNEL_ID',
// //       'CHANNEL_NAME',
// //       importance: Importance.max,
// //       priority: Priority.high,
// //       playSound: true,
// //       //timeoutAfter: 5000,
// //       styleInformation: DefaultStyleInformation(true, true),
// //     );
// //     var platformChannelSpecifics =
// //         NotificationDetails(android: androidChannelSpecifics);    
// //         await flutterLocalNotificationsPlugin.show(
// //       0,
// //       'Test Title',
// //       'Test Body', //null
// //       platformChannelSpecifics,
// //       payload: 'New Payload',
// //     );
// //   }

// // setOnNotificationClick(Function onNotificationClick) async {
// //     await flutterLocalNotificationsPlugin.initialize(initializationSettings,
// //         onDidReceiveBackgroundNotificationResponse: (String payload) async {
// //       onNotificationClick(payload);
// //     });
// //   }
  

// //   setListenerForLowerVersions(Function onNotificationInLowerVersions) {
// //  didReceivedLocalNotificationSubject.listen((receivedNotification) {
// //   onNotificationInLowerVersions(receivedNotification);
// //  });
// // }

// // // Future<void> showWeeklyAtDayAndTime() async {
// // //     var time = Time(20, 0, 0);
// // //     var androidChannelSpecifics = AndroidNotificationDetails(
// // //       'CHANNEL_ID_TIME',
// // //       'CHANNEL_NAME_TIME',
// // //       importance: Importance.max,
// // //       priority: Priority.high,
// // //     );
// // //     var platformChannelSpecifics =
// // //         NotificationDetails(android: androidChannelSpecifics);
// // //     await flutterLocalNotificationsPlugin.zonedSchedule(
// // //       0,
// // //       '${time.hour}:${time.minute}.${time.second}',
// // //       'Test Body', //null
// // //       Day.Saturday,
// // //       time,
// // //       platformChannelSpecifics,
// // //       payload: 'Test Payload',
// // //     );
// // //   }
// // Future<void> cancelNotification() async {
// //   await flutterLocalNotificationsPlugin.cancel(0);
// // }Future<void> cancelAllNotification() async {
// //   await flutterLocalNotificationsPlugin.cancelAll();
// // }
// // Future<int> getPendingNotificationCount() async {
// //     List<PendingNotificationRequest> pendingNotifications =
// //         await flutterLocalNotificationsPlugin.pendingNotificationRequests();
// //     return pendingNotifications.length;
// //   }

// // }

// // NotificationHelper notificationHelper = NotificationHelper();
// // class ReceivedNotification {
// //   final int id;
// //   final String title;
// //   final String body;
// //   final String payload;
// //   ReceivedNotification({
// //     required this.id,
// //     required this.title,
// //     required this.body,
// //     required this.payload,
// //   });
// // }