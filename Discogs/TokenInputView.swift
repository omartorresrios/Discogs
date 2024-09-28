//
//  TokenInputView.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import SwiftUI

struct TokenInputView: View {
	@Environment(\.dismiss) var dismiss
	@AppStorage("authToken") var authToken: String = ""
	@State private var tokenInput: String = ""

	var body: some View {
		VStack {
			Text("Enter Your Token")
			TextField("Token", text: $tokenInput)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.padding()
			Button("Save token") {
				authToken = tokenInput
				dismiss()
			}
		}
		.padding()
	}
}

#Preview {
    TokenInputView()
}
