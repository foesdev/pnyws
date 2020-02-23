import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:pnyws/models/primitives/expense_data.dart';
import 'package:pnyws/models/primitives/trip_data.dart';
import 'package:pnyws/repositories/trip_repository.dart';
import 'package:pnyws/services/shared_prefs.dart';
import 'package:rxdart/rxdart.dart';

const ACTIVE_ITEM_KEY = "ACTIVE_ITEM_KEY";

class TripMockImpl implements TripRepository {
  TripMockImpl({@required this.pref}) {
    final trips = List<TripData>.generate(
      3,
      (index) => TripData(
        title: "Lagos $index",
        items: List.generate(
          Random().nextInt(20),
          (index) => ExpenseData(
            title: "Hello $index",
            value: Random().nextDouble() * 350,
            createdAt: DateTime.now().subtract(Duration(days: 120)).add(Duration(days: index * 10)),
          ),
        ),
        createdAt: DateTime.now().subtract(Duration(days: 120)).add(Duration(days: index * 10)),
      ),
    );
    _tripsController.add(trips);

    final activeItemId = pref.getString(ACTIVE_ITEM_KEY);
    _activeTripController.add(trips.firstWhere((item) => item.id == activeItemId, orElse: () => trips.last));
  }

  final SharedPrefs pref;
  final _activeTripController = BehaviorSubject<TripData>();
  final _tripsController = BehaviorSubject<List<TripData>>();

  @override
  Stream<TripData> getActiveTrip() => _activeTripController.stream;

  @override
  Stream<List<TripData>> getAllTrips() => _tripsController.stream;

  @override
  void setActiveTrip(TripData trip) {
    pref.setString(ACTIVE_ITEM_KEY, trip.id);
    _activeTripController.add(trip);
  }

  @override
  void addNewTrip(TripData trip) {
    _tripsController.add([..._tripsController.value, trip]);
  }
}
