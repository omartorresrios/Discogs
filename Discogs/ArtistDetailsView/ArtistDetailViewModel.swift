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
	private let service: Service
	private var cancellables = Set<AnyCancellable>()
	
	init(service: Service) {
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
		switch error {
		case .badUrl:
			return "The Url request is malformed. We are fixing it right now!"
		case .notFound:
			return error.localizedDescription.description
		case .unknow:
			return "There was an internal error. Please try again later."
		}
	}
}
