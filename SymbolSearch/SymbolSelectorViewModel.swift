//
//  SymbolSelectorViewModel.swift
//  SymbolSearch
//
//  Created by Joshua Homann on 9/18/22.
//

import Combine
import Foundation

@MainActor
final class SymbolSelectorViewModel: ObservableObject {
    @Published var searchTerm = ""
    @Published private(set) var symbols: [String] = []
    private var allSymbols: [String]  = []
    func callAsFunction() async {
        async let loadSymbols = Self.loadSymbols()
        allSymbols = await loadSymbols
        symbols = allSymbols
        async let makeDictionary = await Self.makeTokenDictionary(for: allSymbols)
        let tokenDictionary = await makeDictionary
        for await term in $searchTerm.values.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) {
            guard !term.isEmpty else { continue }
            async let findMatches = Self.matches(for: term, in: allSymbols, tokens: tokenDictionary)
            symbols = await findMatches
        }
    }

    private static func matches(for term: String, in symbols: [String], tokens: [String: Set<Int>]) -> [String] {
        tokens.keys.map { key in
            (levenshteinDistance(key, term), key)
        }
        .sorted { $0.0 < $1.0 }
        .prefix(5)
        .lazy
        .map(\.1)
        .compactMap { tokens[$0] }
        .flatMap { indicies in
            indicies.map { symbols[$0] }
        }
    }

    private static func matches(for term: String, in symbols: [String]) -> [String] {
        symbols.enumerated().map { index, string in
            (levenshteinDistance(string, term), index)
        }
        .sorted { $0.0 < $1.0 }
        .prefix(20)
        .lazy
        .map(\.1)
        .map { index in
            symbols[index]
        }
    }

    private static func makeTokenDictionary(for symbols: [String]) -> [String: Set<Int>] {
        symbols
            .enumerated()
            .reduce(into: [:]) { accumulated, next in
                let (index, element) = next
                let keys = element.components(separatedBy: .init(charactersIn: "."))
                keys.forEach { key in
                    if var set = accumulated[key] {
                        set.insert(index)
                        accumulated[key] = set
                    } else {
                        accumulated[key] = Set([index])
                    }
                }
            }
    }

    private static func loadSymbols() async -> [String]  {
        Bundle(identifier: "com.apple.CoreGlyphs")
            .flatMap { $0.path(forResource: "symbol_search", ofType: "plist") }
            .flatMap { NSDictionary(contentsOfFile: $0) as? [String: Any] }
            .map { plist in plist.keys.sorted() } ?? []
    }
}
