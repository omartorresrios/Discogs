//
//  ArtistDetailsViewModelTests.swift
//  DiscogsTests
//
//  Created by Omar Torres on 9/30/24.
//

import XCTest
import Combine
@testable import Discogs

final class ArtistDetailViewModelTests: XCTestCase {
	
	func test_artistMustHaveDataOnSuccessfulResponse() async {
		let (sut, service) = makeSut()
		service.artist = .dummyArtistDetails
		let expectation = XCTestExpectation(description: "Get artist details")
		
		Task {
			sut.getArtistInfo(id: "344")
			expectation.fulfill()
		}
		await fulfillment(of: [expectation])
		
		XCTAssertNotNil(sut.artist)
		XCTAssertFalse(sut.isLoading)
	}
	
	func test_artistMustBeNilOnFailureResponse() async {
		let (sut, service) = makeSut()
		service.error = .notFound
		let expectation = XCTestExpectation(description: "Get artist results")
		
		Task {
			sut.getArtistInfo(id: "344")
			expectation.fulfill()
		}
		await fulfillment(of: [expectation])
		
		XCTAssertNil(sut.artist)
		XCTAssertFalse(sut.errorMessage.isEmpty)
		XCTAssertFalse(sut.isLoading)
	}
	
	private func makeSut() -> (ArtistDetailViewModel, ArtistServiceStub) {
		let service = ArtistServiceStub()
		let sut = ArtistDetailViewModel(service: service)
		return (sut, service)
	}
	
	final class ArtistServiceStub: ArtistService {
		var artist: ArtistDetails?
		var error: ArtistDetailsError?
		
		func getArtistInfo(id: String) -> AnyPublisher<ArtistDetails, ArtistDetailsError> {
			if let error = error {
				return Fail(error: error).eraseToAnyPublisher()
			} else {
				return Just(artist!)
					.setFailureType(to: ArtistDetailsError.self)
					.eraseToAnyPublisher()
			}
		}
	}
}

