//
//  Service.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import Foundation
import Combine

protocol Service {
	func getSearchResults(with query: String, page: Int) async throws -> [Artist]
	func getArtistInfo(id: String) -> AnyPublisher<ArtistDetails, Error>
}

final class DiscogsService: Service {
	private let authTokenManager: AuthTokenManager
	private let baseUrl = "https://api.discogs.com"
	init(authTokenManager: AuthTokenManager) {
		self.authTokenManager = authTokenManager
	}
	
	func getSearchResults(with query: String, page: Int) async throws -> [Artist] {
		guard let url = URL(string: baseUrl + "/database/search?q=\(query)&type=artist?page=\(page)&per_page=30") else {
			throw SearchRequestError.badUrl
		}
		var request = URLRequest(url: url)
		request.addValue("Discogs token=\(authTokenManager.token)", forHTTPHeaderField: "Authorization")
		do {
			let (data, response) = try await URLSession.shared.data(for: request)
			guard let httpResponse = response as? HTTPURLResponse else {
				throw SearchRequestError.internalServer
			}
			switch httpResponse.statusCode {
			case 200:
				let artistsResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
				return artistsResponse.results
			case 500:
				throw SearchRequestError.internalServer
			default:
				throw SearchRequestError.unknow
			}
		} catch {
			throw error
		}
	}
	
	func getArtistInfo(id: String) -> AnyPublisher<ArtistDetails, Error> {
		guard let url = URL(string: baseUrl + "/artists/\(id)") else {
			return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
		}
		var request = URLRequest(url: url)
		request.addValue("Discogs token=\(authTokenManager.token)", forHTTPHeaderField: "Authorization")
		return URLSession.shared.dataTaskPublisher(for: request)
			.map(\.data)
			.decode(type: ArtistDetails.self, decoder: JSONDecoder())
			.flatMap { [weak self] artist -> AnyPublisher<ArtistDetails, Error> in
				guard let self = self,
					  let albumsURL = URL(string: artist.releasesUrl + "?per_page=30") else {
					return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
				}
				var albumsRequest = URLRequest(url: albumsURL)
				albumsRequest.addValue("Discogs token=\(self.authTokenManager.token)", forHTTPHeaderField: "Authorization")
				return URLSession.shared.dataTaskPublisher(for: albumsRequest)
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
