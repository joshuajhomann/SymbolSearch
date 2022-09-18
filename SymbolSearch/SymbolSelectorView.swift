//
//  SymbolSelectorView.swift
//  SymbolSearch
//
//  Created by Joshua Homann on 9/18/22.
//

import SwiftUI

struct SymbolSelectorView: View {
    @StateObject private var viewModel = SymbolSelectorViewModel()
    @Binding var selectedSymbolName: String?
    @Binding var shouldShow: Bool
    var body: some View {
        NavigationStack {
            List(viewModel.symbols, id: \.self, selection: $selectedSymbolName) { symbol in
                Label {
                    Text(symbol).font(.title)
                } icon: {
                    Image(systemName: symbol).font(.largeTitle)
                }
            }
            .onChange(of: selectedSymbolName) { selection in
                shouldShow = selection == nil
            }
            .navigationTitle("Select Symbol")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Done") { shouldShow = false }
                }
            }
        }
        .task { await viewModel() }
        .searchable(text: $viewModel.searchTerm)
    }
}
