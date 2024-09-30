//
//  DiscogsError.swift
//  Discogs
//
//  Created by Omar Torres on 9/30/24.
//

protocol DiscogsError: Error {
	var localizedDescription: String { get }
}
