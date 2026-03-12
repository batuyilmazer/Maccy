import Defaults
import SwiftUI

struct TagAutocompleteView: View {
  @Binding var query: String
  var allTags: [String]
  @Binding var selectedIndex: Int
  var onAccept: ((String) -> Void)?

  private var suggestions: [String] {
    let parsed = Search.ParsedQuery(from: query)
    guard let partial = parsed.tag, parsed.text.isEmpty, !query.hasSuffix(" ") else { return [] }
    if partial.isEmpty { return allTags }
    return allTags.filter { $0.hasPrefix(partial.lowercased()) }
  }

  var body: some View {
    let suggestions = self.suggestions
    if !suggestions.isEmpty {
      VStack(alignment: .leading, spacing: 0) {
        ForEach(Array(suggestions.enumerated()), id: \.element) { index, tag in
          TagChipView(tag: tag)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(index == clampedIndex(in: suggestions) ? Color.accentColor.opacity(0.3) : .clear)
            .cornerRadius(4)
            .onTapGesture { accept(tag) }
        }
      }
      .padding(4)
      .background(.regularMaterial)
      .cornerRadius(6)
      .shadow(radius: 4)
      .frame(maxWidth: 200, alignment: .leading)
      .onChange(of: query) {
        selectedIndex = 0
      }
    }
  }

  private func clampedIndex(in suggestions: [String]) -> Int {
    guard !suggestions.isEmpty else { return 0 }
    return min(max(selectedIndex, 0), suggestions.count - 1)
  }

  private func accept(_ tag: String) {
    if let onAccept {
      onAccept(tag)
    } else {
      query = "#\(tag) "
    }
    selectedIndex = 0
  }
}
