//
//  ServicesContainer.swift
//  CleanSwiftUI
//
//  Created by Rob Broadwell on 10/16/22.
//

extension DIContainer {
    struct Services {
        let bloombergService: BloombergService
        let yahooFinanceService: YahooFinanceService
        let userPermissionsService: UserPermissionsService
        let imagesService: ImagesService
        
        init(bloombergService: BloombergService,
             yahooFinanceService: YahooFinanceService,
             userPermissionsService: UserPermissionsService,
             imagesService: ImagesService) {
            self.bloombergService = bloombergService
            self.yahooFinanceService = yahooFinanceService
            self.userPermissionsService = userPermissionsService
            self.imagesService = imagesService
        }
        
        static var stub: Self {
            .init(bloombergService: StubBloombergService(),
                  yahooFinanceService: StubYahooFinanceService(),
                  userPermissionsService: StubUserPermissionsService(),
                  imagesService: StubImagesService())
        }
    }
}
