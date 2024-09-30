//
//  ArtistDetailsError.swift
//  Discogs
//
//  Created by Omar Torres on 9/30/24.
//

enum ArtistDetailsError: DiscogsError {
	case badUrl
	case notFound
	case unknown
	
	var description: String {
		switch self {
		case .notFound:
			return "The item cannot be found. Please try again later."
		case .badUrl:
			return "The Url request is malformed. We are fixing it right now!"
		case .unknown:
			return "There was an internal error. Please try again later."
		}
	}
}
