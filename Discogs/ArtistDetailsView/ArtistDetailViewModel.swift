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
	@Published var errorMessage = ""
	private let service: ArtistService
	private var cancellables = Set<AnyCancellable>()
	
	init(service: ArtistService) {
		self.service = service
	}
	
	func getArtistInfo(id: String) {
		isLoading = true
		service.getArtistInfo(id: id)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { [weak self] completion in
				guard let self else { return }
				switch completion {
				case .finished:
					break
				case .failure(let error):
					self.errorMessage = self.setErrorMessage(with: error)
					self.isLoading = false
				}
			}, receiveValue: { [weak self] artist in
				guard let self else { return }
				self.artist = artist
				self.isLoading = false
			})
			.store(in: &cancellables)
	}
	
	private func setErrorMessage(with error: ArtistDetailsError) -> String {
		return error.description
	}
}
