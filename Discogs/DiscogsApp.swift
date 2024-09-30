//
//  DiscogsApp.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import SwiftUI

@main
struct DiscogsApp: App {
	@StateObject private var authTokenManager = AuthTokenManager()
	
    var body: some Scene {
        WindowGroup {
			Group {
				if authTokenManager.token.isEmpty {
					TokenInputView()
				} else {
					SearchView(service: SearchUseCase(authTokenManager: authTokenManager),
							   artistService: ArtistUseCase(authTokenManager: authTokenManager))
				}
			}
			
        }
    }
}
