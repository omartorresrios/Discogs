//
//  AlbumsView.swift
//  Discogs
//
//  Created by Omar Torres on 9/28/24.
//

import SwiftUI

struct AlbumsView: View {
	private var albums: [Album]
	
	init(albums: [Album]) {
		self.albums = albums
	}
	
	var body: some View {
		ScrollView {
			ForEach(albums, id: \.id) { album in
				Text("\(album.id)")
			}
		}
	}
}

#Preview {
	AlbumsView(albums: [.dummyAlbum])
}
