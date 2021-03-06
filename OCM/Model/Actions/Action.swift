//
//  Action.swift
//  OCM
//
//  Created by Alejandro Jiménez on 19/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


protocol Action {
	static func action(from json: JSON) -> Action?
    static func preview(from json: JSON) -> Preview?
    
    var id: String? {get set}
    var preview: Preview? {get set}
    var shareInfo: ShareInfo? {get set}

	func view() -> OrchextraViewController?
    func run(viewController: UIViewController?)
    func executable()
}

// IMPLEMENTATION BY DEFAULT
extension Action {
    
    static func preview(from json: JSON) -> Preview? {
        
        var previewParsed: Preview?

        if let previewJson = json["preview"] {
            previewParsed = PreviewImageText.preview(withJson: previewJson, shareInfo: shareInfo(from: json))
        }
        
        return previewParsed
    }
    
    static func shareInfo(from json: JSON) -> ShareInfo? {
        let url = json["share.url"]?.toString()
        let text = json["share.text"]?.toString()
        
        guard url != nil else { return nil }
        
        return ShareInfo(url: url, text: text)
    }
    
	func view() -> OrchextraViewController? { return nil }
    
    func run(viewController: UIViewController? = nil) { }
    
    func executable() { }
}


class ActionFactory {
	
	class func action(from json: JSON) -> Action? {
		let actions = [
			ActionWebview.action(from: json),
			ActionBrowser.action(from: json),
			ActionContent.action(from: json),
			ActionArticle.action(from: json),
			ActionScanner.action(from: json),
			ActionVuforia.action(from: json),
			ActionCustomScheme.action(from: json),
			ActionYoutube.action(from: json)
		]
		
		// Returns the last action that is not nil, or custom scheme is there is no actions
		return actions.reduce(ActionBanner.action(from: json)) { $1 ?? $0 }
	}
	
}
