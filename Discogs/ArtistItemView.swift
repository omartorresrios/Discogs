//
//  ArtistItemView.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import SwiftUI

struct ArtistItemView: View {
	private var artist: Artist
	
	init(artist: Artist) {
		self.artist = artist
	}
	
	var body: some View {
		HStack {
			if artist.thumb.isEmpty {
				Image(systemName: "person.fill")
					.resizable()
					.aspectRatio(contentMode: .fill)
					.frame(width: 80, height: 80)
					.clipped()
			} else {
				AsyncImage(url: URL(string: artist.thumb)) { image in
					image
						.resizable()
						.aspectRatio(contentMode: .fill)
						.frame(width: 80, height: 80)
						.clipped()
				} placeholder: {
					ProgressView()
						.frame(width: 50, height: 50)
				}
			}
			Text(artist.title)
		}
	}
}

#Preview {
	ArtistItemView(artist: Artist(id: 1, title: "nirvana", thumb: "http://www.thumbnail.com"))
}
