import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/trip.dart';
import '../models/destination.dart';
import '../models/activity.dart';

class TripProvider extends ChangeNotifier {
  final List<Trip> _trips = [];
  final Uuid _uuid = const Uuid();

  List<Trip> get trips => List.unmodifiable(_trips);

  // Trip Methods
  void addTrip({
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final trip = Trip(
      id: _uuid.v4(),
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
    );
    _trips.add(trip);
    notifyListeners();
  }

  void updateTrip({
    required String tripId,
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final index = _trips.indexWhere((trip) => trip.id == tripId);
    if (index != -1) {
      _trips[index] = _trips[index].copyWith(
        name: name,
        description: description,
        startDate: startDate,
        endDate: endDate,
      );
      notifyListeners();
    }
  }

  void deleteTrip(String tripId) {
    _trips.removeWhere((trip) => trip.id == tripId);
    notifyListeners();
  }

  Trip? getTripById(String tripId) {
    try {
      return _trips.firstWhere((trip) => trip.id == tripId);
    } catch (e) {
      return null;
    }
  }

  // Destination Methods
  void addDestination({
    required String tripId,
    required String name,
    required String location,
    required String notes,
  }) {
    final tripIndex = _trips.indexWhere((trip) => trip.id == tripId);
    if (tripIndex != -1) {
      final destination = Destination(
        id: _uuid.v4(),
        name: name,
        location: location,
        notes: notes,
      );
      final trip = _trips[tripIndex];
      final updatedDestinations = [...trip.destinations, destination];
      _trips[tripIndex] = trip.copyWith(destinations: updatedDestinations);
      notifyListeners();
    }
  }

  void updateDestination({
    required String tripId,
    required String destinationId,
    required String name,
    required String location,
    required String notes,
  }) {
    final tripIndex = _trips.indexWhere((trip) => trip.id == tripId);
    if (tripIndex != -1) {
      final trip = _trips[tripIndex];
      final destinationIndex =
          trip.destinations.indexWhere((d) => d.id == destinationId);
      if (destinationIndex != -1) {
        final updatedDestination = trip.destinations[destinationIndex].copyWith(
          name: name,
          location: location,
          notes: notes,
        );
        final updatedDestinations = List<Destination>.from(trip.destinations);
        updatedDestinations[destinationIndex] = updatedDestination;
        _trips[tripIndex] = trip.copyWith(destinations: updatedDestinations);
        notifyListeners();
      }
    }
  }

  void deleteDestination({
    required String tripId,
    required String destinationId,
  }) {
    final tripIndex = _trips.indexWhere((trip) => trip.id == tripId);
    if (tripIndex != -1) {
      final trip = _trips[tripIndex];
      final updatedDestinations = trip.destinations
          .where((d) => d.id != destinationId)
          .toList();
      _trips[tripIndex] = trip.copyWith(destinations: updatedDestinations);
      notifyListeners();
    }
  }

  Destination? getDestinationById(String tripId, String destinationId) {
    final trip = getTripById(tripId);
    if (trip != null) {
      try {
        return trip.destinations.firstWhere((d) => d.id == destinationId);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Activity Methods
  void addActivity({
    required String tripId,
    required String destinationId,
    required String name,
  }) {
    final tripIndex = _trips.indexWhere((trip) => trip.id == tripId);
    if (tripIndex != -1) {
      final trip = _trips[tripIndex];
      final destinationIndex =
          trip.destinations.indexWhere((d) => d.id == destinationId);
      if (destinationIndex != -1) {
        final activity = Activity(
          id: _uuid.v4(),
          name: name,
        );
        final destination = trip.destinations[destinationIndex];
        final updatedActivities = [...destination.activities, activity];
        final updatedDestination = destination.copyWith(activities: updatedActivities);
        final updatedDestinations = List<Destination>.from(trip.destinations);
        updatedDestinations[destinationIndex] = updatedDestination;
        _trips[tripIndex] = trip.copyWith(destinations: updatedDestinations);
        notifyListeners();
      }
    }
  }

  void updateActivity({
    required String tripId,
    required String destinationId,
    required String activityId,
    required String name,
  }) {
    final tripIndex = _trips.indexWhere((trip) => trip.id == tripId);
    if (tripIndex != -1) {
      final trip = _trips[tripIndex];
      final destinationIndex =
          trip.destinations.indexWhere((d) => d.id == destinationId);
      if (destinationIndex != -1) {
        final destination = trip.destinations[destinationIndex];
        final activityIndex =
            destination.activities.indexWhere((a) => a.id == activityId);
        if (activityIndex != -1) {
          final updatedActivity = destination.activities[activityIndex].copyWith(
            name: name,
          );
          final updatedActivities = List<Activity>.from(destination.activities);
          updatedActivities[activityIndex] = updatedActivity;
          final updatedDestination = destination.copyWith(activities: updatedActivities);
          final updatedDestinations = List<Destination>.from(trip.destinations);
          updatedDestinations[destinationIndex] = updatedDestination;
          _trips[tripIndex] = trip.copyWith(destinations: updatedDestinations);
          notifyListeners();
        }
      }
    }
  }

  void deleteActivity({
    required String tripId,
    required String destinationId,
    required String activityId,
  }) {
    final tripIndex = _trips.indexWhere((trip) => trip.id == tripId);
    if (tripIndex != -1) {
      final trip = _trips[tripIndex];
      final destinationIndex =
          trip.destinations.indexWhere((d) => d.id == destinationId);
      if (destinationIndex != -1) {
        final destination = trip.destinations[destinationIndex];
        final updatedActivities = destination.activities
            .where((a) => a.id != activityId)
            .toList();
        final updatedDestination = destination.copyWith(activities: updatedActivities);
        final updatedDestinations = List<Destination>.from(trip.destinations);
        updatedDestinations[destinationIndex] = updatedDestination;
        _trips[tripIndex] = trip.copyWith(destinations: updatedDestinations);
        notifyListeners();
      }
    }
  }

  void toggleActivityCompletion({
    required String tripId,
    required String destinationId,
    required String activityId,
  }) {
    final tripIndex = _trips.indexWhere((trip) => trip.id == tripId);
    if (tripIndex != -1) {
      final trip = _trips[tripIndex];
      final destinationIndex =
          trip.destinations.indexWhere((d) => d.id == destinationId);
      if (destinationIndex != -1) {
        final destination = trip.destinations[destinationIndex];
        final activityIndex =
            destination.activities.indexWhere((a) => a.id == activityId);
        if (activityIndex != -1) {
          final activity = destination.activities[activityIndex];
          final updatedActivity = activity.copyWith(
            isCompleted: !activity.isCompleted,
          );
          final updatedActivities = List<Activity>.from(destination.activities);
          updatedActivities[activityIndex] = updatedActivity;
          final updatedDestination = destination.copyWith(activities: updatedActivities);
          final updatedDestinations = List<Destination>.from(trip.destinations);
          updatedDestinations[destinationIndex] = updatedDestination;
          _trips[tripIndex] = trip.copyWith(destinations: updatedDestinations);
          notifyListeners();
        }
      }
    }
  }
}

