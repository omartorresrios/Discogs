//
//  Service.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import Foundation

final class Service {
	
	static func getArtists(url: URL) async throws -> [Artist] {
		let request = URLRequest(url: url)
		let (data, _) = try await URLSession.shared.data(for: request)
		let artistsResponse = try JSONDecoder().decode(ArtistResponse.self, from: data)
		return artistsResponse.results
	}
}
