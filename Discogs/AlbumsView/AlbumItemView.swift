//
//  AlbumItemView.swift
//  Discogs
//
//  Created by Omar Torres on 9/29/24.
//

import SwiftUI

struct AlbumItemView: View {
	private let album: Album
	
	init(_ album: Album) {
		self.album = album
	}
	
    var body: some View {
		HStack(spacing: 8) {
			if let url = URL(string: album.thumb) {
				AsyncImage(url: url) { image in
					image
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 50, height: 50)
						.clipped()
				} placeholder: {
					ProgressView()
						.frame(width: 50, height: 50)
				}
			} else {
				VStack {
					Text("No thumbnail")
				}
				.frame(width: 50, height: 50)
			}
			VStack(alignment: .leading) {
				Text("Title: \(album.title)")
				Text("Type: \(album.type)")
				Text("Year: \(album.year)")
			}
		}
    }
}

#Preview {
	AlbumItemView(.dummyAlbum)
}
