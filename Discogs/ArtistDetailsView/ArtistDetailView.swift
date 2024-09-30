//
//  ArtistDetailView.swift
//  Discogs
//
//  Created by Omar Torres on 9/27/24.
//

import SwiftUI

struct ArtistDetailView: View {
	@StateObject private var viewModel: ArtistDetailViewModel
	@State var showingAlbumsView = false
	@State var showingBandMembersView = false
	private let artist: Artist
	
	init(artist: Artist, service: Service) {
		self.artist = artist
		_viewModel = StateObject(wrappedValue: ArtistDetailViewModel(service: service))
	}
	
    var body: some View {
		ScrollView {
			VStack(spacing: 10) {
				if let primaryImageUrl = viewModel.artist?.images?.first(where: { $0.type == "primary" })?.resourceUrl,
				   let url = URL(string: primaryImageUrl) {
					AsyncImage(url: url) { image in
						image
							.resizable()
							.aspectRatio(contentMode: .fit)
							.clipped()
					} placeholder: {
						ProgressView()
							.frame(width: 50, height: 50)
					}
				}
				VStack(alignment: .leading, spacing: 10) {
					HStack {
						Text(viewModel.artist?.name ?? "")
						Spacer()
						VStack(alignment: .trailing) {
							if viewModel.artist?.albums != nil {
								Button("See albums") {
									showingAlbumsView = true
								}
							}
							if !(viewModel.artist?.members ?? []).isEmpty {
								Button("See band members") {
									showingBandMembersView = true
								}
							}
						}
					}
					Text(viewModel.artist?.profile ?? "")
				}
				
				.padding(.horizontal)
				
			}
		}
		.sheet(isPresented: $showingAlbumsView) {
			AlbumsView(albums: viewModel.artist?.albums ?? [])
			.presentationDetents([.medium])
		}
		.sheet(isPresented: $showingBandMembersView) {
			MembersView(members: viewModel.artist?.members ?? [])
			.presentationDetents([.medium])
		}
		.onAppear {
			viewModel.getArtistInfo(id: "\(artist.id)")
		}
    }
}

#Preview {
	ArtistDetailView(artist: .dummyArtist, service: DiscogsService(authTokenManager: AuthTokenManager()))
		.environmentObject(AuthTokenManager())
}
