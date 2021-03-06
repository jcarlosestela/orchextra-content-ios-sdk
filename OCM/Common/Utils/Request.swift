//
//  RequestExtension.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 3/11/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


extension Request {
	
	class func OCMRequest(method: String,
	                      endpoint: String,
	                      urlParams: [String: Any]? = nil,
	                      bodyParams: [String: Any]? = nil) -> Request {
		return Request (
			method: method,
			baseUrl: Config.Host,
			endpoint: endpoint,
			headers: self.headers(),
			urlParams: urlParams,
			bodyParams: bodyParams,
			verbose: OCM.shared.logLevel == .debug
		)
	}
	
	private class func headers() -> [String: String] {
		let accessToken = Session.shared.loadAccessToken() ?? "no_token_set"
        let acceptLanguage: String = Session.shared.languageCode ?? Locale.currentLanguage()
		
		return [
			"Authorization": "Bearer \(accessToken)",
			"Accept-Language": acceptLanguage,
			"X-ocm-version": Config.SDKVersion
		]
	}
	
}
