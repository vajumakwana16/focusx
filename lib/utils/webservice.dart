import 'package:shared_preferences/shared_preferences.dart';

import '../services/firestore_service.dart';

class Webservice {

  static late SharedPreferences pref;

   static FirestoreService firebaseService = FirestoreService();

}