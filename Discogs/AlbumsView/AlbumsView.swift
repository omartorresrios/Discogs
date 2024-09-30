//
//  AlbumsView.swift
//  Discogs
//
//  Created by Omar Torres on 9/28/24.
//

import SwiftUI

struct AlbumsView: View {
	@StateObject private var viewModel = AlbumsViewModel()
	@State var selectedOrder: AlbumsOrder = .year
	private var albums: [Album]
	
	init(albums: [Album]) {
		self.albums = albums
	}
	
	var body: some View {
		VStack {
			Menu("Sort By") {
				ForEach(AlbumsOrder.allCases, id: \.self) { orderType in
					if orderType == .year {
						Button {
							selectedOrder = orderType
						} label: {
							HStack {
								if selectedOrder == orderType {
									Image(systemName: "checkmark")
								}
								Text(orderType.description)
							}
						}
					} else {
						Menu {
							ForEach(viewModel.allLabels, id: \.self) { label in
								Button(label) {
									selectedOrder = orderType
									viewModel.sortAlbumsByLabel(label)
								}
							}
						} label: {
							HStack {
								if selectedOrder == orderType {
									Image(systemName: "checkmark")
								}
								Text(orderType.description)
							}
						}
					}
					Button("Clear filter") {
						viewModel.setAlbums(albums: albums)
						selectedOrder = .year
					}
				}
				.padding()
				HStack {
					Text("Albums")
						.padding()
				}
				ScrollView {
					VStack(alignment: .leading) {
						ForEach(viewModel.albums, id: \.id) { album in
							HStack {
								if let url = URL(string: album.thumb) {
									AsyncImage(url: url) { image in
										image
											.resizable()
											.aspectRatio(contentMode: .fit)
											.frame(width: 50, height: 50)
											.clipped()
									} placeholder: {
										ProgressView()
											.background(.green)
											.frame(width: 50, height: 50)
									}
								} else {
									VStack {
										Text("No thumbnail")
									}
									.frame(width: 80, height: 80)
									.background(.red)
								}
								VStack(alignment: .leading) {
									Text("Title: \(album.title)")
									Text("Type: \(album.type)")
									Text("Year: \(album.year)")
								}
								.padding(.leading, 8)
							}
							.background(.red)
							.padding(.vertical, 4)
						}
					}
					.padding(.horizontal)
				}
			}
			.onAppear {
				viewModel.setAlbums(albums: albums)
			}
		}
	}
	
	#Preview {
		AlbumsView(albums: [.dummyAlbum])
	}
}
