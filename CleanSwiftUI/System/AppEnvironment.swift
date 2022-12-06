//
//  AppEnvironment.swift
//  CleanSwiftUI
//
//  Created by Rob Broadwell on 10/16/22.
//

import UIKit
import Combine

struct AppEnvironment {
    let container: DIContainer
    let systemEventsHandler: SystemEventsHandler
}

extension AppEnvironment {
    
    static func bootstrap() -> AppEnvironment {
        let appState = Store<AppState>(AppState())
        
        let session = configuredURLSession()
        let webRepositories = configuredWebRepositories(session: session)
        let dbRepositories = configuredDBRepositories(appState: appState)
        let services = configuredServices(appState: appState,
                                          dbRepositories: dbRepositories,
                                          webRepositories: webRepositories)
        
        let diContainer = DIContainer(appState: appState, services: services)
        let deepLinksHandler = RealDeepLinksHandler(container: diContainer)
        let pushNotificationsHandler = RealPushNotificationsHandler(deepLinksHandler: deepLinksHandler)
        
        let systemEventsHandler = RealSystemEventsHandler(
            container: diContainer, deepLinksHandler: deepLinksHandler,
            pushNotificationsHandler: pushNotificationsHandler,
            pushTokenWebRepository: webRepositories.pushTokenWebRepository)
        
        return AppEnvironment(container: diContainer, systemEventsHandler: systemEventsHandler)
    }
    
    private static func configuredURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 120
        configuration.waitsForConnectivity = true
        configuration.httpMaximumConnectionsPerHost = 5
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.urlCache = .shared
        return URLSession(configuration: configuration)
    }
    
    private static func configuredWebRepositories(session: URLSession) -> DIContainer.WebRepositories {
        let bloombergWebRepository = RealBloombergWebRepository(
            session: session,
            baseURL: "https://restcountries.com/v2")
        let yahooFinanceWebRepository = RealYahooFinanceWebRepository(
            session: session,
            baseURL: "https://ezgif.com")
        let pushTokenWebRepository = RealPushTokenWebRepository(
            session: session,
            baseURL: "https://fake.backend.com")
        let imageWebRepository = RealImageWebRepository(
            session: session,
            baseURL: "https://ezgif.com")
        return .init(bloombergRepository: bloombergWebRepository,
                     yahooFinanceRepository: yahooFinanceWebRepository,
                     pushTokenWebRepository: pushTokenWebRepository,
                     imageRepository: imageWebRepository)
    }
    
    private static func configuredDBRepositories(appState: Store<AppState>) -> DIContainer.DBRepositories {
        let persistentStore = CoreDataStack(version: CoreDataStack.Version.actual)
        let bloombergDBRepository = RealBloombergDBRepository(persistentStore: persistentStore)
        let yahooFinanceDBRepository = RealYahooFinanceDBRepository(persistentStore: persistentStore)
        
        return .init(bloombergRepository: bloombergDBRepository,
                     yahooFinanceRepository: yahooFinanceDBRepository)
    }
    
    private static func configuredServices(appState: Store<AppState>,
                                           dbRepositories: DIContainer.DBRepositories,
                                           webRepositories: DIContainer.WebRepositories) -> DIContainer.Services {
        
        let bloombergService = RealBloombergService(
            webRepository: webRepositories.bloombergRepository,
            dbRepository: dbRepositories.bloombergRepository,
            appState: appState)
        
        let yahooFinanceService = RealYahooFinanceService(
            webRepository: webRepositories.yahooFinanceRepository,
            dbRepository: dbRepositories.yahooFinanceRepository,
            appState: appState)
        
        let userPermissionsService = RealUserPermissionsService(
            appState: appState, openAppSettings: {
                URL(string: UIApplication.openSettingsURLString).flatMap {
                    UIApplication.shared.open($0, options: [:], completionHandler: nil)
                }
            })
        
        let imagesService = RealImagesService(
            webRepository: webRepositories.imageRepository)
        
        return .init(bloombergService: bloombergService,
                     yahooFinanceService: yahooFinanceService,
                     userPermissionsService: userPermissionsService,
                     imagesService: imagesService)
    }
}

extension DIContainer {
    struct WebRepositories {
        let bloombergRepository: BloombergWebRepository
        let yahooFinanceRepository: YahooFinanceWebRepository
        let pushTokenWebRepository: PushTokenWebRepository
        let imageRepository: ImageWebRepository
    }
    
    struct DBRepositories {
        let bloombergRepository: BloombergDBRepository
        let yahooFinanceRepository: YahooFinanceDBRepository
    }
}
