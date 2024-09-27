//
//  SearchView.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import SwiftUI

struct Artist: Identifiable, Decodable {
	var id: Int
	let title: String
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
								Text(artist.title)
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
