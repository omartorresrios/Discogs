//
//  ArtistDetailView.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import SwiftUI

struct ArtistDetailView: View {
	@StateObject private var viewModel = ArtistDetailViewModel()
	@EnvironmentObject var authTokenManager: AuthTokenManager
	@State var showingAlbumsView = false
	private var artist: Artist
	
	init(searchResult: Artist) {
		self.artist = searchResult
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
				Button("See albums") {
					showingAlbumsView = true
				}
			}
		}
		.sheet(isPresented: $showingAlbumsView) {
			AlbumsView(albums: viewModel.artist?.albums ?? [])
			.presentationDetents([.medium])
		}
		.onAppear {
			viewModel.getArtistInfo(id: "\(artist.id)", authToken: authTokenManager.token)
		}
    }
}

#Preview {
	ArtistDetailView(searchResult: .dummyArtist)
}
