//
//  SearchViewModel.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import Combine
import Foundation

final class SearchViewModel: ObservableObject {
	@Published var searchText: String = ""
	@Published var searchResults: [Artist] = []
	@Published var isLoading: Bool = false
	private let service: Service
	private var cancellables = Set<AnyCancellable>()
	
	init(service: Service) {
		self.service = service
		$searchText
			.debounce(for: .milliseconds(300), scheduler: RunLoop.main)
			.removeDuplicates()
			.sink { [weak self] in self?.getArtists(with: $0) }
			.store(in: &cancellables)
	}

	func getArtists(with query: String) {
		guard !query.isEmpty else {
			searchResults = []
			return
		}
		guard let url = URL(string: "https://api.discogs.com/database/search?q=\(query)") else {
			return
		}
		isLoading = true
		Task {
			do {
				let searchResults = try await service.getSearchResults(url: url)
				await MainActor.run {
					self.searchResults = searchResults
					isLoading = false
				}
			} catch {
				print("An error ocurred while fetching artists: ", error)
				await MainActor.run {
					isLoading = false
				}
			}
		}
	}
}

