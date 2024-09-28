//
//  SearchView.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import SwiftUI

struct Artist: Identifiable, Decodable {
	let id: Int
	let title: String
	let thumb: String
}

struct ArtistResponse: Decodable {
	let results: [Artist]
}

struct SearchView: View {
	@StateObject private var viewModel = SearchViewModel()
	@AppStorage("authToken") var authToken: String = ""
	
	let artists: [Artist] = []
	
    var body: some View {
		NavigationStack {
			ZStack {
				List(viewModel.artists) { artist in
					ArtistItemView(artist: artist)
				}
				.navigationTitle("Search Artists")
				.searchable(text: $viewModel.searchText)
				.overlay(
					Group {
						if viewModel.isLoading {
							ProgressView()
						} else if viewModel.artists.isEmpty && !viewModel.searchText.isEmpty {
							Text("No results found")
								.foregroundColor(.gray)
						} else if viewModel.searchText.isEmpty {
							Text("Search for an artist!")
						}
					}
				)
			}
		}
		.onAppear {
			viewModel.setAuthToken(authToken)
		}
    }
}

#Preview {
    SearchView()
}
