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
	private let service: Service
	private var cancellables = Set<AnyCancellable>()
	
	init(service: Service) {
		self.service = service
	}
	
	func getArtistInfo(id: String) {
		guard let url = URL(string: "https://api.discogs.com/artists/\(id)") else {
			return
		}
		isLoading = true
		service.getArtistInfo(url: url)
		.receive(on: DispatchQueue.main)
		.sink(receiveCompletion: { [weak self] completion in
			guard let self else {
				return
			}
			switch completion {
			case .finished:
				break
			case .failure(let error):
				print("some error: ", error)
//				self.errorMessage = error.localizedDescription
				self.isLoading = false
			}
		}, receiveValue: { [weak self] artist in
			guard let self else { return }
			self.artist = artist
			self.isLoading = false
		})
		.store(in: &cancellables)
	}
}
