import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart' as here_core;
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/core.threading.dart';
import 'package:here_sdk/mapview.dart' as here_map;
import 'package:here_sdk/routing.dart' as here_route;
import 'package:here_sdk/search.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:treeroute/providers/providers.dart';

class SearchState {
  final SearchEngine? searchEngine;
  final List<Suggestion> suggestions;
  final Suggestion? selectedSuggestion;
  final String? searchQuery;

  SearchState({
    this.searchEngine,
    this.suggestions = const [],
    this.selectedSuggestion,
    this.searchQuery,
  });

  SearchState copyWith({
    SearchEngine? searchEngine,
    List<Suggestion>? suggestions,
    Suggestion? selectedSuggestion,
    String? searchQuery,
  }) {
    return SearchState(
      searchEngine: searchEngine ?? this.searchEngine,
      suggestions: suggestions ?? this.suggestions,
      selectedSuggestion: selectedSuggestion ?? this.selectedSuggestion,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  SearchState deleteSuggestions() {
    return SearchState(
      searchEngine: searchEngine,
      suggestions: [],
      selectedSuggestion: selectedSuggestion,
      searchQuery: searchQuery,
    );
  }

  @override
  String toString() {
    return 'SearchState(searchEngine: $searchEngine, suggestions: $suggestions, selectedSuggestion: $selectedSuggestion, searchQuery: $searchQuery)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchState &&
        other.searchEngine == searchEngine &&
        listEquals(other.suggestions, suggestions) &&
        other.selectedSuggestion == selectedSuggestion &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    return searchEngine.hashCode ^
        suggestions.hashCode ^
        selectedSuggestion.hashCode ^
        searchQuery.hashCode;
  }
}

class SearchProvider extends StateNotifier<SearchState> {
  Ref ref;
  SearchProvider(this.ref)
      : super(SearchState(
          searchEngine: SearchEngine(),
        ));

  void initRoutingEngine() {
    try {
      state = state.copyWith(searchEngine: SearchEngine());
    } on InstantiationException {
      throw ("Initialization of RoutingEngine failed.");
    }
  }

  TaskHandle searchSuggestions(
    String text,
    void Function(SearchError? error, List<Suggestion>? suggestions) callback,
  ) {
    here_core.GeoCoordinates centerGeoCoordinates = here_core.GeoCoordinates(
      ref.read(locationProvider).latestLocation?.latitude ?? 0,
      ref.read(locationProvider).latestLocation?.longitude ?? 0,
    );

    SearchOptions searchOptions = SearchOptions.withDefaults();
    searchOptions.languageCode = here_core.LanguageCode.enUs;
    searchOptions.maxItems = 5;

    TextQueryArea queryArea = TextQueryArea.withCircle(
      here_core.GeoCircle(
        centerGeoCoordinates,
        10000,
      ),
    );

    return state.searchEngine!
        .suggest(TextQuery.withArea(text, queryArea), searchOptions,
            (error, suggestions) {
      callback(error, suggestions);
      if (error != null) {
        state = state.copyWith(
            suggestions: suggestions
                ?.where((element) => element.place?.geoCoordinates != null)
                .toList(),
            searchQuery: text);
      }
    });
  }

  void selectSuggestion(Suggestion suggestion) {
    state = state.copyWith(selectedSuggestion: suggestion);
  }

  void clearSuggestions() {
    state = state.deleteSuggestions();
  }
}
