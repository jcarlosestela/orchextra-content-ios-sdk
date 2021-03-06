//
//  WebInteractor.swift
//  OCM
//
//  Created by Carlos Vicente on 11/1/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

public enum PassbookError {
	case error(NSError)
	case unsupportedVersionError(NSError)
}

class WebInteractor {
	let passBookWrapper: PassbookWrapperProtocol
	var passbookResult: PassbookWrapperResult?
	
	init(passbookWrapper: PassbookWrapperProtocol) {
		self.passBookWrapper = passbookWrapper
	}
	
	func userDidProvokeRedirection(with url: URL, completionHandler: @escaping (PassbookWrapperResult) -> Void) {
		if self.urlHasValidPassbookFormat(url: url) {
			self.performAction(for: url, completionHandler: completionHandler)
		}
	}
	
	func urlHasValidPassbookFormat(url: URL) -> Bool {
		return url.lastPathComponent == "passbook" || url.lastPathComponent.hasSuffix("pkpass")
	}
	
	private func performAction(for url: URL, completionHandler: @escaping (PassbookWrapperResult) -> Void) {
		let urlString = url.absoluteString
		self.passBookWrapper.addPassbook(from: urlString) { result in
			switch result {
			case .success:
				completionHandler(.success)
				
			case .unsupportedVersionError(let error):
				completionHandler(.unsupportedVersionError(error))
				
			case .error(let error):
				completionHandler(.error(error))
			}
			
			self.passbookResult = result
		}
	}
}
