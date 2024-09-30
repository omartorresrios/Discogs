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
	private let service: Service
	private var cancellables = Set<AnyCancellable>()
	
	init(service: Service) {
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
				switch error {
				case .internalServer:
					await setErrorMessage(with: error.localizedDescription.description)
				case .badUrl:
					await setErrorMessage(with: "The Url request is malformed. We are fixing it right now!")
				case .unknow:
					await setErrorMessage(with: "There was an internal error. Please try again.")
				}
				await MainActor.run {
					self.isLoading = false
				}
			}
		}
	}
	
	private func setErrorMessage(with message: String) async {
		await MainActor.run {
			errorMessage = message
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
