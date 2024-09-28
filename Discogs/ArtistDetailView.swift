//
//  ArtistDetailView.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import SwiftUI

struct ArtistDetailView: View {
	private var artist: Artist
	
	init(artist: Artist) {
		self.artist = artist
	}
	
    var body: some View {
		Text(artist.title)
    }
}

#Preview {
	ArtistDetailView(artist: Artist(id: 1, title: "nirvana", thumb: "http://www.thumbnail.com"))
}
