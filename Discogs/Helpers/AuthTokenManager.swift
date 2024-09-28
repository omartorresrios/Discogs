//
//  AuthToken.swift
//  Discogs
//
//  Created by Omar Torres on 9/28/24.
//

import SwiftUI

class AuthTokenManager: ObservableObject {
	@AppStorage("authToken") private var storedToken: String = ""

	var token: String {
		get { storedToken }
		set { storedToken = newValue }
	}
}
