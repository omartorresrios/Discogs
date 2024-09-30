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
	private var currentPage = 1
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
			currentPage = 1
			return
		}
		isLoading = true
		currentPage = 1
		Task {
			do {
				let searchResults = try await service.getSearchResults(with: query, page: currentPage)
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
			} catch {
				print("An error occurred while loading more artists: ", error)
				await MainActor.run {
					self.isLoading = false
				}
			}
		}
	}
	
	func showLoader() -> Bool {
		isLoading && !searchResults.isEmpty
	}
	
	func showNoResults() -> Bool {
		searchResults.isEmpty && !searchText.isEmpty
	}
	
	func showEmptyView() -> Bool {
		searchText.isEmpty
	}
}
