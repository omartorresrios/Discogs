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
	func getArtistInfo(id: String) -> AnyPublisher<ArtistDetails, ArtistDetailsError>
}

final class DiscogsService: Service {
	private let authTokenManager: AuthTokenManager
	private let baseUrl = "https://api.discogs.com"
	
	init(authTokenManager: AuthTokenManager) {
		self.authTokenManager = authTokenManager
	}
	
	private func makeRequest<T: DiscogsError>(with url: String, 
											  errorType: T.Type) throws -> URLRequest {
		guard let url = URL(string: url) else {
			throw T.self == SearchRequestError.self ? SearchRequestError.badUrl : ArtistDetailsError.badUrl
		}
		var request = URLRequest(url: url)
		request.addValue("Discogs token=\(authTokenManager.token)", forHTTPHeaderField: "Authorization")
		return request
	}
	
	func getSearchResults(with query: String, page: Int) async throws -> [Artist] {
		let urlString = "\(baseUrl)/database/search?q=\(query)&type=artist&page=\(page)&per_page=30"
		let request = try makeRequest(with: urlString, errorType: SearchRequestError.self)
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
				throw SearchRequestError.unknown
			}
		} catch {
			throw error
		}
	}
	
	func getArtistInfo(id: String) -> AnyPublisher<ArtistDetails, ArtistDetailsError> {
		let urlString = "\(baseUrl)/artists/\(id)"
		do {
			let request = try makeRequest(with: urlString, errorType: ArtistDetailsError.self)
			return URLSession.shared.dataTaskPublisher(for: request)
				.tryMap { result in
					guard let httpResponse = result.response as? HTTPURLResponse else {
						throw ArtistDetailsError.unknown
					}
					switch httpResponse.statusCode {
					case 200:
						return result.data
					case 404:
						throw ArtistDetailsError.notFound
					default:
						throw ArtistDetailsError.unknown
					}
				}
				.decode(type: ArtistDetails.self, decoder: JSONDecoder())
				.mapError { error -> ArtistDetailsError in
					return error as? ArtistDetailsError ?? .unknown
				}
				.flatMap { [weak self] artist -> AnyPublisher<ArtistDetails, ArtistDetailsError> in
					guard let self = self else {
						return Fail(error: ArtistDetailsError.unknown).eraseToAnyPublisher()
					}
					return self.fetchAlbums(for: artist)
				}
				.eraseToAnyPublisher()
		} catch {
			return Fail(error: error as? ArtistDetailsError ?? .unknown).eraseToAnyPublisher()
		}
	}
	
	private func fetchAlbums(for artist: ArtistDetails) -> AnyPublisher<ArtistDetails, ArtistDetailsError> {
		do {
			let albumsRequest = try makeRequest(with: artist.releasesUrl + "?per_page=30", errorType: ArtistDetailsError.self)
			return URLSession.shared.dataTaskPublisher(for: albumsRequest)
				.tryMap { albumsResult in
					guard let httpResponse = albumsResult.response as? HTTPURLResponse else {
						throw ArtistDetailsError.unknown
					}
					switch httpResponse.statusCode {
					case 200:
						return albumsResult.data
					case 404:
						throw ArtistDetailsError.notFound
					default:
						throw ArtistDetailsError.unknown
					}
				}
				.decode(type: AlbumResponse.self, decoder: JSONDecoder())
				.mapError { error -> ArtistDetailsError in
					return error as? ArtistDetailsError ?? .unknown
				}
				.map { albumsResponse in
					var updatedArtist = artist
					updatedArtist.albums = albumsResponse.releases
					return updatedArtist
				}
				.eraseToAnyPublisher()
		} catch {
			return Fail(error: error as? ArtistDetailsError ?? .unknown).eraseToAnyPublisher()
		}
	}
}
