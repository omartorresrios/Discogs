//
//  Service.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import Foundation
import Combine

final class Service {
	
	static func getSearchResults(url: URL) async throws -> [Artist] {
		let request = URLRequest(url: url)
		let (data, _) = try await URLSession.shared.data(for: request)
		let artistsResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
		return artistsResponse.results
	}
	
	func getArtistInfo(url: URL) -> AnyPublisher<ArtistDetails, Error> {
		return URLSession.shared.dataTaskPublisher(for: url)
			.map(\.data)
			.decode(type: ArtistDetails.self, decoder: JSONDecoder())
			.flatMap { artist -> AnyPublisher<ArtistDetails, Error> in
				guard let albumsURL = URL(string: artist.releasesUrl) else {
					return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
				}
				return URLSession.shared.dataTaskPublisher(for: albumsURL)
					.map(\.data)
					.decode(type: AlbumResponse.self, decoder: JSONDecoder())
					.map { albumsResponse in
						var updatedArtist = artist
						updatedArtist.albums = albumsResponse.releases
						return updatedArtist
					}
					.eraseToAnyPublisher()
			}
			.eraseToAnyPublisher()
	}
}
