import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/place.dart';

class PlaceState {
  final List<Place> places;
  final Place? selectedPlace;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  PlaceState({
    required this.places,
    required this.selectedPlace,
    required this.isLoading,
    required this.error,
    required this.searchQuery,
  });

  PlaceState copyWith({
    List<Place>? places,
    Place? selectedPlace,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return PlaceState(
      places: places ?? this.places,
      selectedPlace: selectedPlace ?? this.selectedPlace,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PlaceProvider extends StateNotifier<PlaceState> {
  Ref ref;
  PlaceProvider(this.ref)
      : super(
          PlaceState(
            places: [],
            selectedPlace: null,
            isLoading: false,
            error: null,
            searchQuery: '',
          ),
        );

  void selectPlace(Place place) {
    state = state.copyWith(selectedPlace: place);
  }

  void searchPlaces(String query) async {
    state = state.copyWith(searchQuery: query, isLoading: true);
    try {
      final response = await Supabase.instance.client
          .rpc("search_location", params: {"location_term": query});
      final places = response.map((e) => Place.fromMap(e)).toList();
      state = state.copyWith(places: places, isLoading: false);
    } on PostgrestException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          error: "Unkown error ocurred while searching", isLoading: false);
    }
  }
}
