import Defaults
import KeyboardShortcuts
import SwiftUI

struct ListHeaderView: View {
  @FocusState.Binding var searchFocused: Bool
  @Binding var searchQuery: String

  @Environment(AppState.self) private var appState
  @Environment(\.scenePhase) private var scenePhase

  @Default(.showTitle) private var showTitle

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        if showTitle {
          Text("Maccy")
            .foregroundStyle(.secondary)
            .padding(.leading, 5)
        }

        SearchFieldView(placeholder: "search_placeholder", query: $searchQuery)
          .focused($searchFocused)
          .frame(maxWidth: .infinity)
          .onChange(of: scenePhase) {
            if scenePhase == .background && !searchQuery.isEmpty {
              searchQuery = ""
            }
          }
          // Only reliable way to disable the cursor. allowsHitTesting() does not work
          .offset(y: appState.searchVisible ? 0 : -Popup.itemHeight)
      }

      TagAutocompleteView(
        query: $searchQuery,
        allTags: appState.history.allTags,
        selectedIndex: Bindable(appState).tagAutocompleteIndex
      )
      .onChange(of: searchQuery) {
        let parsed = Search.ParsedQuery(from: searchQuery)
        let hasTagPrefix = parsed.tag != nil
        let isActivelyTypingTag = hasTagPrefix && parsed.text.isEmpty && !searchQuery.hasSuffix(" ")
        let hasSuggestions = isActivelyTypingTag && !appState.history.allTags.isEmpty
        appState.tagAutocompleteActive = hasSuggestions
        appState.tagAutocompleteIndex = 0
      }
    }
  }
}
