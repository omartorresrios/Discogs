//
//  Artist.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

struct SearchResponse: Decodable {
	let results: [Artist]
}

struct Artist: Identifiable, Decodable, Hashable {
	let id: Int
	let title: String
	let thumb: String
	let coverImage: String
	let type: String
	
	enum CodingKeys: String, CodingKey {
		case coverImage = "cover_image"
		case id, title, thumb, type
	}
}

extension Artist {
	static let dummyArtist = Artist(id: 1,
									title: "Nirvana",
									thumb: "http://www.thumbnail.com",
									coverImage: "http://www.cover-image.com",
									type: "artist")
}
