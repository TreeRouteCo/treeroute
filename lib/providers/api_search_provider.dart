import 'package:flutter/foundation.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/search.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchState {
  final SupabaseClient? supaClient;
  final List<Suggestion> suggestions;
  final Suggestion? selectedSuggestion;
  final String? searchQuery;

  SearchState({
    this.supaClient,
    this.suggestions = const [],
    this.selectedSuggestion,
    this.searchQuery,
  });

  SearchState copyWith({
    SupabaseClient? supaClient,
    List<Suggestion>? suggestions,
    Suggestion? selectedSuggestion,
    String? searchQuery,
  }) {
    return SearchState(
      supaClient: supaClient ?? this.supaClient,
      suggestions: suggestions ?? this.suggestions,
      selectedSuggestion: selectedSuggestion ?? this.selectedSuggestion,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  SearchState deleteSelectedSuggestion() {
    return SearchState(
      supaClient: supaClient,
      suggestions: suggestions,
      selectedSuggestion: null,
      searchQuery: searchQuery,
    );
  }

  SearchState deleteSearchQuery() {
    return SearchState(
      supaClient: supaClient,
      suggestions: suggestions,
      selectedSuggestion: selectedSuggestion,
      searchQuery: null,
    );
  }

  SearchState deleteSuggestions() {
    return SearchState(
      supaClient: supaClient,
      suggestions: [],
      selectedSuggestion: selectedSuggestion,
      searchQuery: searchQuery,
    );
  }

  @override
  String toString() {
    return 'SearchState(supaClient: $supaClient, suggestions: $suggestions, selectedSuggestion: $selectedSuggestion, searchQuery: $searchQuery)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchState &&
        other.supaClient == supaClient &&
        listEquals(other.suggestions, suggestions) &&
        other.selectedSuggestion == selectedSuggestion &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    return supaClient.hashCode ^
        suggestions.hashCode ^
        selectedSuggestion.hashCode ^
        searchQuery.hashCode;
  }
}

class SearchProvider extends StateNotifier<SearchState> {
  Ref ref;
  SearchProvider(this.ref)
      : super(SearchState(
          supaClient: Supabase.instance.client,
        ));

  void initRoutingEngine() {
    try {
      state = state.copyWith(supaClient: Supabase.instance.client);
    } on InstantiationException {
      throw ("Initialization of SearchEngine failed.");
    }
  }

  void searchSuggestions(
    String text,
    void Function(SearchError? error, List<Suggestion>? suggestions) callback,
  ) {
    /*SearchOptions searchOptions = SearchOptions.withDefaults();
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
      if (error == null) {
        state = state.copyWith(
          suggestions: suggestions
              ?.where((element) => element.place?.geoCoordinates != null)
              .toList(),
          searchQuery: text,
        );
      }
    });*/
  }

  void selectSuggestion(Suggestion suggestion) {
    state = state.copyWith(selectedSuggestion: suggestion);
  }

  void clearSearch() {
    state = state
        .deleteSuggestions()
        .deleteSearchQuery()
        .deleteSelectedSuggestion();
  }

  void clearSelectedSuggestion() {
    state = state.deleteSelectedSuggestion();
  }
}
