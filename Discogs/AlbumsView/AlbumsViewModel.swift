//
//  AlbumsViewModel.swift
//  Discogs
//
//  Created by Omar Torres on 9/29/24.
//

import Foundation

final class AlbumsViewModel: ObservableObject {
	@Published var albums = [Album]()
	
	var allLabels: [String] {
		return Array(Set(albums.compactMap { $0.label })).sorted()
	}

	func sortAlbumsByYear() {
		albums.sort { $0.year > $1.year }
	}

	func sortAlbumsByLabel(_ label: String) {
		albums = albums.filter { $0.label?.contains(label) ?? false }
	}
	
	func setAlbums(albums: [Album]) {
		self.albums = albums
	}
}
