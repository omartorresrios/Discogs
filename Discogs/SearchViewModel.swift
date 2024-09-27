//
//  SearchViewModel.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import Combine
import Foundation

class SearchViewModel: ObservableObject {
	@Published var searchText: String = ""
	private var authToken = ""
	@Published var artists: [Artist] = []
	@Published var isLoading: Bool = false
	private var cancellables = Set<AnyCancellable>()
	
	init() {
		$searchText
			.debounce(for: .milliseconds(300), scheduler: RunLoop.main)
			.removeDuplicates()
			.sink { [weak self] in self?.getArtists(with: $0) }
			.store(in: &cancellables)
	}

	func getArtists(with query: String) {
		guard !query.isEmpty else {
			artists = []
			return
		}
		guard let url = URL(string: "https://api.discogs.com/database/search?q=\(query)&type=artist&token=\(authToken)") else {
			return
		}
		isLoading = true
		Task {
			do {
				let artists = try await Service.getArtists(url: url)
				await MainActor.run {
					self.artists = artists
					isLoading = false
				}
			} catch {
				print("An error ocurred while fetching artists")
				await MainActor.run {
					isLoading = false
				}
			}
		}
	}
	
	func setAuthToken(_ authToken: String) {
		self.authToken = authToken
	}
}

