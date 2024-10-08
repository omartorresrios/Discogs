//
//  SearchViewModel.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import Combine
import Foundation

final class SearchViewModel: ObservableObject {
	@Published var searchText = ""
	@Published var searchResults: [Artist] = []
	@Published var isLoading = false
	@Published var errorMessage = ""
	private var currentPage = 1
	private let service: SearchService
	private var cancellables = Set<AnyCancellable>()
	
	init(service: SearchService) {
		self.service = service
		subscribeToSearchText()
	}
	
	private func subscribeToSearchText() {
		$searchText
			.debounce(for: .milliseconds(300), scheduler: RunLoop.main)
			.removeDuplicates()
			.sink { [weak self] in
				guard let self else { return }
				if !$0.isEmpty {
					self.getArtists(with: $0)
				} else {
					self.searchResults = []
					currentPage = 1
				}
			}
			.store(in: &cancellables)
	}
	
	func getArtists(with query: String) {
		isLoading = true
		currentPage = 1
		Task {
			do {
				let searchResults = try await service.getSearchResults(with: query, page: currentPage)
				await MainActor.run {
					self.searchResults = searchResults
					isLoading = false
				}
			} catch let error as SearchRequestError {
				await MainActor.run {
					self.setErrorMessage(with: error)
					self.isLoading = false
				}
			}
		}
	}
	
	private func setErrorMessage(with error: SearchRequestError) {
		errorMessage = error.description
	}
	
	func loadMoreArtists(result: Artist) {
		guard result == searchResults.last && !isLoading else { return }
		isLoading = true
		Task {
			do {
				let newResults = try await service.getSearchResults(with: searchText, page: currentPage + 1)
				await MainActor.run {
					let uniqueNewResults = newResults.filter { newArtist in
						!self.searchResults.contains(where: { $0.id == newArtist.id })
					}
					self.searchResults.append(contentsOf: uniqueNewResults)
					self.currentPage += 1
					self.isLoading = false
				}
			} catch let error as SearchRequestError {
				await MainActor.run {
					self.setErrorMessage(with: error)
					self.isLoading = false
				}
			}
		}
	}
	
	func showErrorMessage() -> Bool {
		!errorMessage.isEmpty
	}
	
	func showNoResults() -> Bool {
		searchResults.isEmpty && !searchText.isEmpty
	}
	
	func showEmptyView() -> Bool {
		searchText.isEmpty
	}
}
