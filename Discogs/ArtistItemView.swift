//
//  ArtistItemView.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import SwiftUI

struct ArtistItemView: View {
	private var artist: Artist
	
	init(searchResult: Artist) {
		self.artist = searchResult
	}
	
	var body: some View {
		HStack {
			if artist.thumb.isEmpty {
				VStack {
					Text("No thumbnail")
				}
				.frame(width: 80, height: 80)
				.background(.red)
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
	ArtistItemView(searchResult: Artist(id: 1, title: "nirvana", thumb: "http://www.thumbnail.com", coverImage: "", type: ""))
}
