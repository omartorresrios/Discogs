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
	let members: [Member]?
	var albums: [Album]?
	
	
	enum CodingKeys: String, CodingKey {
		case releasesUrl = "releases_url"
		case id, name, images, profile, members, albums
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

extension ArtistDetails {
	static let dummyArtistDetails = ArtistDetails(id: 1,
												  name: "Nirvana",
												  images: [],
												  profile: "some profile info",
												  releasesUrl: "http://www.some-url.com",
												  members: [],
												  albums: [])
}

struct Member: Decodable {
	let id: Int
	let name: String
	let thumbnailUrl: String
	
	enum CodingKeys: String, CodingKey {
		case thumbnailUrl = "thumbnail_url"
		case id, name
	}
}

extension Member {
	static let dummyMember = Member(id: 2, 
									name: "George",
									thumbnailUrl: "http://www.some-thumb.com")
}
