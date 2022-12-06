//
//  YahooFinanceWebRepository.swift
//  CleanSwiftUI
//
//  Created by Rob Broadwell on 10/16/22.
//

import Combine
import Foundation

protocol YahooFinanceWebRepository: WebRepository {
    func loadCountries() -> AnyPublisher<[Country], Error>
    func loadCountryDetails(country: Country) -> AnyPublisher<Country.Details.Intermediate, Error>
}

struct RealYahooFinanceWebRepository: YahooFinanceWebRepository {
    
    let session: URLSession
    let baseURL: String
    let bgQueue = DispatchQueue(label: "bg_parse_queue")
    
    init(session: URLSession, baseURL: String) {
        self.session = session
        self.baseURL = baseURL
    }
    
    func loadCountries() -> AnyPublisher<[Country], Error> {
        return call(endpoint: API.allCountries)
    }

    func loadCountryDetails(country: Country) -> AnyPublisher<Country.Details.Intermediate, Error> {
        let request: AnyPublisher<[Country.Details.Intermediate], Error> = call(endpoint: API.countryDetails(country))
        return request
            .tryMap { array -> Country.Details.Intermediate in
                guard let details = array.first
                    else { throw APIError.unexpectedResponse }
                return details
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Endpoints

extension RealYahooFinanceWebRepository {
    enum API {
        case allCountries
        case countryDetails(Country)
    }
}

extension RealYahooFinanceWebRepository.API: APICall {
    var path: String {
        switch self {
        case .allCountries:
            return "/all"
        case let .countryDetails(country):
            let encodedName = country.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            return "/name/\(encodedName ?? country.name)"
        }
    }
    var method: String {
        switch self {
        case .allCountries, .countryDetails:
            return "GET"
        }
    }
    var headers: [String: String]? {
        return ["Accept": "application/json"]
    }
    func body() throws -> Data? {
        return nil
    }
}


