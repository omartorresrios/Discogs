//
//  SearchUseCase.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import Foundation
import Combine

final class SearchUseCase: SearchService {
	private let authTokenManager: AuthTokenManager
	
	init(authTokenManager: AuthTokenManager) {
		self.authTokenManager = authTokenManager
	}
	
	func getSearchResults(with query: String, page: Int) async throws -> [Artist] {
		let urlString = "https://api.discogs.com/database/search?q=\(query)&type=artist&page=\(page)&per_page=30"
		let request = try GenericRequest.make(with: urlString,
													 token: authTokenManager.token,
													 errorType: SearchRequestError.self)
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
}
