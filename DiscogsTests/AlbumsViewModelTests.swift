//
//  AlbumsViewModelTests.swift
//  DiscogsTests
//
//  Created by Omar Torres on 9/30/24.
//

import XCTest
@testable import Discogs

final class AlbumsViewModelTests: XCTestCase {
	
	func test_getAllNotNilAlbumLabels() {
		let sut = makeSut()
		sut.setAlbums(albums: [.dummyAlbum, .dummyAlbum1])
		
		XCTAssertEqual(sut.allLabels.count, 1)
	}
	
	func test_sortAlbumsMustBeFromNwestToOldest() {
		let sut = makeSut()
		sut.setAlbums(albums: [.dummyAlbum, .dummyAlbum1])
		
		XCTAssertEqual(sut.albums.first, .dummyAlbum)
	}
	
	func test_sortAlbumsByLabelShouldReturnMatchedLabels() {
		let sut = makeSut()
		sut.setAlbums(albums: [.dummyAlbum, .dummyAlbum1])
		
		sut.sortAlbumsByLabel("GRD")
		
		XCTAssertEqual(sut.albums, [.dummyAlbum])
	}
	
	private func makeSut() -> AlbumsViewModel {
		let sut = AlbumsViewModel()
		return sut
	}
}
