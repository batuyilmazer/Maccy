import SwiftUI

struct TagInputView: View {
  @Environment(AppState.self) private var appState
  @FocusState private var isFocused: Bool
  @State private var autocompleteIndex: Int = 0

  private var suggestions: [String] {
    let query = appState.taggingQuery.lowercased()
    guard !query.isEmpty else { return appState.history.allTags }
    return appState.history.allTags.filter { $0.hasPrefix(query) }
  }

  var body: some View {
    if appState.isTagging {
      let suggestions = self.suggestions
      VStack(alignment: .leading, spacing: 0) {
        HStack(spacing: 4) {
          Image(systemName: "tag")
            .foregroundStyle(.secondary)
            .frame(width: 12, height: 12)
          TextField(
            "",
            text: Bindable(appState).taggingQuery,
            prompt: Text("TagInputPlaceholder", tableName: "TagSettings")
          )
          .textFieldStyle(.plain)
          .focused($isFocused)
          .onSubmit {
            if !suggestions.isEmpty && !appState.taggingQuery.isEmpty {
              let index = min(max(autocompleteIndex, 0), suggestions.count - 1)
              appState.taggingQuery = suggestions[index]
            }
            appState.commitTag()
          }
          .onExitCommand {
            appState.cancelTagging()
          }
          .onKeyPress(.downArrow) {
            if !suggestions.isEmpty {
              autocompleteIndex = min(autocompleteIndex + 1, suggestions.count - 1)
            }
            return .handled
          }
          .onKeyPress(.upArrow) {
            autocompleteIndex = max(autocompleteIndex - 1, 0)
            return .handled
          }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)

        if !suggestions.isEmpty {
          Divider()
          ScrollView {
            VStack(alignment: .leading, spacing: 0) {
              ForEach(Array(suggestions.enumerated()), id: \.element) { index, tag in
                let clamped = min(max(autocompleteIndex, 0), suggestions.count - 1)
                TagChipView(tag: tag)
                  .padding(.horizontal, 8)
                  .padding(.vertical, 3)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .background(index == clamped ? Color.accentColor.opacity(0.3) : .clear)
                  .cornerRadius(4)
                  .onTapGesture {
                    appState.taggingQuery = tag
                    appState.commitTag()
                  }
              }
            }
          }
          .frame(maxHeight: 120)
          .padding(.vertical, 2)
        }
      }
      .background(.regularMaterial)
      .cornerRadius(6)
      .shadow(radius: 4)
      .frame(width: 200)
      .onAppear {
        autocompleteIndex = 0
        Task {
          try? await Task.sleep(for: .milliseconds(150))
          isFocused = true
        }
      }
      .onChange(of: appState.taggingQuery) {
        autocompleteIndex = 0
      }
    }
  }
}
