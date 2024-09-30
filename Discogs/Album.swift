//
//  Album.swift
//  Discogs
//
//  Created by Omar Torres on 9/30/24.
//

struct AlbumResponse: Decodable {
	let releases: [Album]
}

struct Album: Decodable, Equatable {
	let id: Int
	let title: String
	let type: String
	let year: Int?
	let label: String?
	let thumb: String
}

extension Album {
	static let dummyAlbum = Album(id: 1,
								  title: "album",
								  type: "master",
								  year: 1990,
								  label: "GRD",
								  thumb: "https://api.discogs.com/masters/155876")
	
	static let dummyAlbum1 = Album(id: 2,
								  title: "album 2",
								  type: "master",
								  year: 1960,
								   label: nil,
								  thumb: "https://api.discogs.com/masters/155876")
}
