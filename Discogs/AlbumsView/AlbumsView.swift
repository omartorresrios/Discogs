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
	private let albums: [Album]
	
	init(albums: [Album]) {
		self.albums = albums
	}
	
	var body: some View {
		VStack {
			VStack(spacing: 5) {
				Text("Albums")
					.font(.title2)
				sortView
			}
			.padding()
			albumList
		}
		.onAppear {
			viewModel.setAlbums(albums: albums)
		}
	}
	
	private var sortView: some View {
		Menu("Sort By") {
			ForEach(AlbumsOrder.allCases, id: \.self) { orderType in
				if orderType == .year {
					yearOption(orderType)
				} else {
					labelOption(orderType)
				}
			}
			Button("Clear filter") {
				viewModel.setAlbums(albums: albums)
				selectedOrder = .year
			}
		}
	}
	
	private func yearOption(_ orderType: AlbumsOrder) -> some View {
		Button {
			selectedOrder = orderType
		} label: {
			orderText(for: orderType)
		}
	}
	
	private func labelOption(_ orderType: AlbumsOrder) -> some View {
		Menu {
			ForEach(viewModel.allLabels, id: \.self) { label in
				Button(label) {
					selectedOrder = orderType
					viewModel.sortAlbumsByLabel(label)
				}
			}
		} label: {
			orderText(for: orderType)
		}
	}
	
	private func orderText(for orderType: AlbumsOrder) -> some View {
		HStack {
			if selectedOrder == orderType {
				Image(systemName: "checkmark")
			}
			Text(orderType.description)
		}
	}
	
	private var albumList: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 10) {
				ForEach(viewModel.albums, id: \.id) { album in
					AlbumItemView(album)
				}
			}
			.padding(.horizontal)
		}
	}
}

#Preview {
	AlbumsView(albums: [.dummyAlbum, .dummyAlbum])
}
