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
	@State var showingBanMembersView = false
	private var artist: Artist
	
	init(artist: Artist) {
		self.artist = artist
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
				if let albums = viewModel.artist?.albums {
					Button("See albums") {
						showingAlbumsView = true
					}
				}
				if !(viewModel.artist?.members ?? []).isEmpty {
					Button("See band members") {
						showingBanMembersView = true
					}
				}
			}
		}
		.sheet(isPresented: $showingAlbumsView) {
			AlbumsView(albums: viewModel.artist?.albums ?? [])
			.presentationDetents([.medium])
		}
		.sheet(isPresented: $showingBanMembersView) {
			ScrollView {
				ForEach(viewModel.artist?.members ?? [], id: \.id) { member in
					Text("\(member.name)")
				}
			}
			.presentationDetents([.medium])
		}
		.onAppear {
			viewModel.getArtistInfo(id: "\(artist.id)", authToken: authTokenManager.token)
		}
    }
}

#Preview {
	ArtistDetailView(artist: .dummyArtist)
}
