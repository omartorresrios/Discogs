//
//  DiscogsApp.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import SwiftUI

@main
struct DiscogsApp: App {
	@AppStorage("authToken") var authToken: String = ""
	
    var body: some Scene {
        WindowGroup {
			if authToken.isEmpty {
				TokenInputView()
			} else {
				SearchView()
			}
        }
    }
}
