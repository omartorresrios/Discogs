//
//  SearchView.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import SwiftUI

struct SearchView: View {
	@StateObject private var viewModel: SearchViewModel
	private let service: SearchService
	let artistService: ArtistService
	
	init(service: SearchService, artistService: ArtistService) {
		self.service = service
		self.artistService = artistService
		_viewModel = StateObject(wrappedValue: SearchViewModel(service: service))
	}
	
    var body: some View {
		NavigationStack {
			ZStack {
				List(viewModel.searchResults) { result in
					NavigationLink(value: result) {
						ArtistItemView(searchResult: result)
					}
					.onAppear {
						viewModel.loadMoreArtists(result: result)
					}
				}
				if viewModel.isLoading {
					VStack {
						ProgressView()
							.progressViewStyle(CircularProgressViewStyle(tint: .white))
							.frame(height: 100)
					}
					.frame(width: 100, height: 100)
					.background(Color.black.opacity(0.7))
					.cornerRadius(15)
				} else if viewModel.showNoResults() {
					Text("No results found")
				} else if viewModel.showEmptyView() {
					Text("Search for an artist!")
				} else if viewModel.showErrorMessage() {
					Text(viewModel.errorMessage)
				}
			}
			.navigationTitle("Search Artists")
			.searchable(text: $viewModel.searchText)
			.navigationDestination(for: Artist.self) { result in
				ArtistDetailView(artist: result, service: artistService)
			}
		}
    }
}

#Preview {
	SearchView(service: SearchUseCase(authTokenManager: AuthTokenManager()), 
			   artistService: ArtistUseCase(authTokenManager: AuthTokenManager()))
}
