//
//  ContentView.swift
//  SymbolSearch
//
//  Created by Joshua Homann on 9/9/22.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedSymbolName: String?
    @State private var showSelectSymbol = false
    var body: some View {
        VStack {
            if let selectedSymbolName {
                Image(systemName: selectedSymbolName)
                    .font(.largeTitle)
            }
            Text(selectedSymbolName ?? "no symbol selected")
            Button("Select symbol") { showSelectSymbol.toggle() }
        }
        .padding()
        .sheet(isPresented: $showSelectSymbol) {
            SymbolSelectorView(selectedSymbolName: $selectedSymbolName, shouldShow: $showSelectSymbol)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
