//
//  DiscogsApp.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import SwiftUI

@main
struct DiscogsApp: App {
	@State private var isShowingTokenInputView = true
	@AppStorage("authToken") var authToken: String = ""
	
    var body: some Scene {
        WindowGroup {
            SearchView()
			.fullScreenCover(isPresented: $isShowingTokenInputView) {
				TokenInputView()
			}
			.onAppear {
				isShowingTokenInputView = authToken.isEmpty
			}
        }
    }
}
