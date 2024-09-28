//
//  TokenInputView.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import SwiftUI

struct TokenInputView: View {
	@Environment(\.dismiss) var dismiss
	@State private var tokenInput: String = ""
	@EnvironmentObject var authTokenManager: AuthTokenManager

	var body: some View {
			VStack {
				Text("Enter Your Token")
				TextField("Token", text: $tokenInput)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.padding()
				Button("Save Token") {
					authTokenManager.token = tokenInput
				}
			}
			.padding()
		}
}

#Preview {
    TokenInputView()
}
