//
//  Service.swift
//  Discogs
//
//  Created by Omar Torres on 9/30/24.
//

import Foundation
import Combine

enum GenericRequest {
	static func make<T: DiscogsError>(with url: String,
									  token: String,
									  errorType: T.Type) throws -> URLRequest {
		guard let url = URL(string: url) else {
			throw T.self == SearchRequestError.self ? SearchRequestError.badUrl : ArtistDetailsError.badUrl
		}
		var request = URLRequest(url: url)
		request.addValue("Discogs token=\(token)", forHTTPHeaderField: "Authorization")
		return request
	}
}

protocol SearchService {
	func getSearchResults(with query: String, page: Int) async throws -> [Artist]
}

protocol ArtistService {
	func getArtistInfo(id: String) -> AnyPublisher<ArtistDetails, ArtistDetailsError>
}
