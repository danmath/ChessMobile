//
//  ContentView.swift
//  ChessMobile
//
//  Created by Daniel Mathews on 9/15/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        BoardView(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.width)
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
