//
//  ArtistDetails.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import Foundation

struct ArtistDetails: Decodable {
	let id: Int
	let name: String
	let images: [ArtistImage]?
	let profile: String
	let releasesUrl: String
	var albums: [Album]?
	
	enum CodingKeys: String, CodingKey {
		case releasesUrl = "releases_url"
		case id, name, images, profile, albums
	}
}

struct ArtistImage: Decodable {
	let type: String
	let uri: String
	let resourceUrl: String
	let uri150: String
	let width: Int
	let height: Int
	
	enum CodingKeys: String, CodingKey {
		case resourceUrl = "resource_url"
		case type, uri, uri150, width, height
	}
}

struct AlbumResponse: Decodable {
	let releases: [Album]
}

struct Album: Decodable {
	let id: Int
	let title: String
}

extension Album {
	static let dummyAlbum = Album(id: 1, title: "album")
}
