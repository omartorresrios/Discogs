//
//  SearchViewModelTests.swift
//  DiscogsTests
//
//  Created by Omar Torres on 9/27/24.
//

import XCTest
import Combine
@testable import Discogs

final class SearchViewModelTests: XCTestCase {

	private var cancellables = Set<AnyCancellable>()
	
	func test_searchResultsMustHaveDataOnSuccessfulResponse() async {
		let (sut, service) = makeSut()
		service.artists = [.dummyArtist]
		let expectation = XCTestExpectation(description: "Get artist results")
		
		Task {
			sut.getArtists(with: "Nirvana")
			expectation.fulfill()
		}
		await fulfillment(of: [expectation])
		
		XCTAssertFalse(sut.searchResults.isEmpty)
		XCTAssertFalse(sut.isLoading)
	}
	
	func test_searchResultsMustBeEmptyOnFailureResponse() async {
		let (sut, service) = makeSut()
		service.error = .internalServer
		let expectation = XCTestExpectation(description: "Get artist results")
		
		Task {
			sut.getArtists(with: "Nirvana")
			expectation.fulfill()
		}
		await fulfillment(of: [expectation])
		
		XCTAssertTrue(sut.searchResults.isEmpty)
		XCTAssertFalse(sut.errorMessage.isEmpty)
		XCTAssertFalse(sut.isLoading)
	}
	
	func test_searchTextValuesMustBeTheSameAsQueryWhenSubscribed() async {
		let (sut, service) = makeSut()
		service.artists = [.dummyArtist]
		let searchTextSpy = SearchTextSpy(sut.$searchText.eraseToAnyPublisher())
		
		sut.searchText = "Nirvana"
		
		XCTAssertEqual(searchTextSpy.values, ["Nirvana"])
	}
	
	func test_searchResultsMustBeEmptyWhenQueryIsEmpty() {
		let (sut, service) = makeSut()
		service.artists = [.dummyArtist]
		let expectation = XCTestExpectation(description: "Get request query")
		
		sut.searchText = ""
		sut.$searchText
			.sink { value in
				XCTAssertTrue(sut.searchResults.isEmpty)
				expectation.fulfill()
		}.store(in: &cancellables)
		wait(for: [expectation], timeout: 1.0)
	}
	
	func test_startLoadingMoreArtistIfSearchResultsIsEmptyAndIsNotLoading() async {
		let (sut, service) = makeSut()
		service.artists = [.dummyArtist, .dummyArtist1]
		let expectation = XCTestExpectation(description: "Get artist results")
		
		Task {
			sut.getArtists(with: "Nirvana")
			expectation.fulfill()
		}
		await fulfillment(of: [expectation])
		sut.loadMoreArtists(result: .dummyArtist1)
		
		XCTAssertTrue(sut.isLoading)
		XCTAssertFalse(sut.searchResults.isEmpty)
	}
	
	func test_showNoResultsWhenSearchResultIsEmptyAndQueryIsNotEmpty() async {
		let (sut, service) = makeSut()
		service.artists = []
		let expectation = XCTestExpectation(description: "Get artist results")
		
		Task {
			sut.getArtists(with: "Nirvana")
			expectation.fulfill()
		}
		sut.searchText = "Nirvana"
		await fulfillment(of: [expectation])
		
		XCTAssertTrue(sut.showNoResults())
	}
	
	func test_showEmptyViewWhenSearchTextIsEmpty() async {
		let (sut, _) = makeSut()
		
		sut.searchText = ""
		
		XCTAssertTrue(sut.showEmptyView())
	}
	
	func test_showErrorMessageIfErrorMessageIsNotEmpty() async {
		let (sut, _) = makeSut()
		
		sut.errorMessage = "Some error"
		
		XCTAssertTrue(sut.showErrorMessage())
	}
	
	private func makeSut() -> (SearchViewModel, DiscogsServiceStub) {
		let service = DiscogsServiceStub()
		let sut = SearchViewModel(service: service)
		return (sut, service)
	}
	
	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}
	
	private class SearchTextSpy {
		private(set) var values = [String]()
		private var cancellables = Set<AnyCancellable>()
		
		init(_ publisher: AnyPublisher<String, Never>) {
			publisher
				.dropFirst()
				.sink { [weak self] value in
				self?.values.append(value)
			}.store(in: &cancellables)
		}
	}
	
	final class DiscogsServiceStub: SearchService {
		var artists: [Artist]?
		var error: SearchRequestError?
		
		func getSearchResults(with query: String, page: Int) async throws -> [Artist] {
			if let error = error {
				throw error
			} else {
				return artists ?? []
			}
		}
	}
}
