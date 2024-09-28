//
//  ArtistDetailViewModel.swift
//  Discogs
//
//  Created by Omar Torres on 9/28/24.
//

import Foundation
import Combine

final class ArtistDetailViewModel: ObservableObject {
	@Published var isLoading = false
	@Published var artist: ArtistDetails?
	private var cancellables = Set<AnyCancellable>()
	
	func getArtistInfo(id: String, authToken: String) {
		guard let url = URL(string: "https://api.discogs.com/artists/\(id)?token=\(authToken)") else {
			return
		}
		isLoading = true
		Service().getArtistInfo(url: url)
		.receive(on: DispatchQueue.main)
		.sink(receiveCompletion: { completion in
			switch completion {
			case .finished:
				break
			case .failure(let error):
				print("some error: ", error)
//				self.errorMessage = error.localizedDescription
				self.isLoading = false
			}
		}, receiveValue: { artist in
			self.artist = artist
			self.isLoading = false
		})
		.store(in: &cancellables)
	}
}
