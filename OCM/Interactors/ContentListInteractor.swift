//
//  ContentListInteractor.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

enum ContentListResult {
    case success(contents: ContentList)
    case empty
    case error(message: String)
}

protocol ContentListInteractorProtocol {
    func contentList(from path: String, completionHandler: @escaping (ContentListResult) -> Void)
    func contentList(matchingString string: String, completionHandler: @escaping (ContentListResult) -> Void)
}

struct ContentListInteractor: ContentListInteractorProtocol {
    
    let service: PContentListService
    let storage: Storage
    
	func contentList(from path: String, completionHandler: @escaping (ContentListResult) -> Void) {
        self.service.getContentList(with: path) { result in
            let contentListResult = self.contentListResult(fromWigetListServiceResult: result)
            completionHandler(contentListResult)
        }
    }
    
    func contentList(matchingString string: String, completionHandler: @escaping (ContentListResult) -> Void) {
        self.service.getContentList(matchingString: string) {  result in
            let contentListResult = self.contentListResult(fromWigetListServiceResult: result)
            completionHandler(contentListResult)
        }
    }
    
    // MARK: - Convenience Methods
    
    func contentListResult(fromWigetListServiceResult wigetListServiceResult: WigetListServiceResult) -> ContentListResult {
        switch wigetListServiceResult {
            
        case .success(let contentList):
            if !contentList.contents.isEmpty {
                return(.success(contents: contentList))
                
            } else {
                return(.empty)
            }
            
        case .error(let error):
            return(.error(message: error.errorMessageOCM()))
        }
    }
}

fileprivate extension Bool {
    static func random() -> Bool {
        return arc4random_uniform(2) == 0
    }
}
