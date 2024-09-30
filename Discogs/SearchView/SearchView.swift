//
//  SearchView.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import SwiftUI

struct SearchView: View {
	@StateObject private var viewModel: SearchViewModel
	private let service: Service
	
	init(service: Service) {
		self.service = service
		_viewModel = StateObject(wrappedValue: SearchViewModel(service: service))
	}
	
    var body: some View {
		NavigationStack {
			ZStack {
				List(viewModel.searchResults) { result in
					NavigationLink(value: result) {
						ArtistItemView(searchResult: result)
					}
				}
				.navigationTitle("Search Artists")
				.searchable(text: $viewModel.searchText)
				.overlay(
					Group {
						if viewModel.isLoading {
							ProgressView()
						} else if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty {
							Text("No results found")
								.foregroundColor(.gray)
						} else if viewModel.searchText.isEmpty {
							Text("Search for an artist!")
						}
					}
				)
				.navigationDestination(for: Artist.self) { result in
					ArtistDetailView(artist: result, service: service)
				}
			}
		}
    }
}

#Preview {
	SearchView(service: DiscogsService(authTokenManager: AuthTokenManager()))
}
