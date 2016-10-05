//
//  ContentListInteractor.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation

enum ContentListResult {
    case success(contents: [Content])
    case empty
    case error(message: String)
}


struct ContentListInteractor {
    
    let service: PContentListService
    let storage: Storage
    
	func contentList(from uri: String, completionHandler: @escaping (ContentListResult) -> Void) {
		guard let contentAction = ActionFactory.action(from: uri) as? ActionContent else { return LogWarn("Uri returned no action") }
		let slug = contentAction.slug
		
        self.service.getContentList(with: slug) { result in
            switch result {
                
            case .success(let contents):
                self.storage.contentList = contents
                
                if contents.count > 0 {
                    completionHandler(.success(contents: contents))
                }
                else {
                    completionHandler(.empty)
                }
                
            case .error(let error):
                completionHandler(.error(message: error.errorMessage()))
            }
        }
    }
    
}
