//
//  CountriesViewModel.swift
//  CountriesChallenge
//

import Combine
import Foundation

class CountriesViewModel {
    // Make service injectable for testing
    let service: CountriesService
    
    init(service: CountriesService = CountriesService()) {
        self.service = service
    }

    private(set) var countriesSubject = CurrentValueSubject<[Country], Never>([])
    private(set) var errorSubject = CurrentValueSubject<Error?, Never>(nil)

    func refreshCountries() {
        Task {
            do {
                let countries = try await service.fetchCountries()
                self.countriesSubject.value = countries
            } catch {
                self.errorSubject.value = error
            }
        }
    }
}
