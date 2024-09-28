//
//  ArtistDetailView.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import SwiftUI

struct ArtistDetailView: View {
	@StateObject private var viewModel = ArtistDetailViewModel()
	private var artist: Artist
	private var authToken = ""
	
	init(searchResult: Artist, authToken: String) {
		self.artist = searchResult
		self.authToken = authToken
	}
	
    var body: some View {
		ScrollView {
			HStack {
				AsyncImage(url: URL(string: artist.coverImage)) { image in
					image
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 50, height: 50)
						.clipped()
				} placeholder: {
					ProgressView()
						.frame(width: 50, height: 50)
				}
				VStack {
					Text(artist.title)
					Text(artist.type)
				}
			}
			VStack {
				if let primaryImageUrl = viewModel.artist?.images?.first(where: { $0.type == "primary" })?.resourceUrl,
				   let url = URL(string: primaryImageUrl) {
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
				}
				Text(viewModel.artist?.name ?? "")
				Text(viewModel.artist?.profile ?? "")
				Text("Albums:")
					.background(.red)
				ForEach(viewModel.artist?.albums ?? [], id: \.id) { album in
					Text("\(album.id)")
				}
			}
		}
		.onAppear {
			viewModel.getArtistInfo(id: "\(artist.id)", authToken: authToken)
		}
    }
}

#Preview {
	ArtistDetailView(searchResult: Artist(id: 1, title: "nirvana", thumb: "http://www.thumbnail.com", coverImage: "https://st.discogs.com/5da07aaaa33ce7e947e10287f90bca903336d4e3/images/spacer.gif", type: "artist"), authToken: "token")
}
