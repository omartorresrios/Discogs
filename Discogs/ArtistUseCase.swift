//
//  ArtistUseCase.swift
//  Discogs
//
//  Created by Omar Torres on 9/30/24.
//

import Foundation
import Combine

final class ArtistUseCase: ArtistService {
	private let authTokenManager: AuthTokenManager
	
	init(authTokenManager: AuthTokenManager) {
		self.authTokenManager = authTokenManager
	}
	
	func getArtistInfo(id: String) -> AnyPublisher<ArtistDetails, ArtistDetailsError> {
		let urlString = "https://api.discogs.com/artists/\(id)"
		do {
			let request = try GenericRequest.make(with: urlString,
												  token: authTokenManager.token,
												  errorType: ArtistDetailsError.self)
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
			let albumsRequest = try GenericRequest.make(with: artist.releasesUrl + "?per_page=30",
														token: authTokenManager.token,
														errorType: ArtistDetailsError.self)
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
