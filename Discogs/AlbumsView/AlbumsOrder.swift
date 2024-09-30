//
//  AlbumsOrder.swift
//  Discogs
//
//  Created by Omar Torres on 9/29/24.
//

enum AlbumsOrder: CaseIterable {
	case year
	case label
	
	var description: String {
		switch self {
		case .year:
			return "Year"
		case .label:
			return "Label"
		}
	}
}
