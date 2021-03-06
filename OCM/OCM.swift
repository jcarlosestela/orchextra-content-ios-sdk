//
//  OCM.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 30/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary
/**
The OCM class provides you with methods for starting the framework and retrieve the ViewControllers to use within your app.


### Usage

You should use the `shared` property to get a unique singleton instance, then set your `logLevel`


### Overview

Once the framework is started, you can retrive the ViewControllers to show the content list


- Since: 1.0
- Version: 1.0
- Author: Alejandro Jiménez Agudo
- Copyright: Gigigo S.L.
*/

public protocol StatusView {
    func instantiate() -> UIView
}

public protocol ErrorView {
    static func instantiate() -> ErrorView
    func set(errorDescription: String)
    func set(retryBlock: @escaping () -> Void)
    func view() -> UIView
}

open class OCM: NSObject {
	
	public static let shared = OCM()
	
	/**
	Type of OCM's logs you want displayed in the debug console
	
	- **none**: No log will be shown. Recommended for production environments.
	- **error**: Only warnings and errors. Recommended for develop environments.
	- **info**: Errors and relevant information. Recommended for testing OCM integration.
	- **debug**: Request and Responses to OCM's server will be displayed. Not recommended to use, only for debugging OCM.
	*/
	public var logLevel: LogLevel {
		didSet {
			LogManager.shared.logLevel = self.logLevel
		}
	}
	
	//swiftlint:disable weak_delegate
	public var delegate: OCMDelegate?
	public var analytics: OCMAnalytics?
	//swiftlint:enable weak_delegate
	
	
	public var host: String {
		didSet {
			Config.Host = self.host
		}
	}
	
	public var countryCode: String? {
		didSet {
			if let countryCode = self.countryCode {
				OrchextraWrapper.shared.setCountry(code: countryCode)
			}
		}
	}
	
	public var userID: String? {
		didSet {
			OrchextraWrapper.shared.setUser(id: userID)
		}
	}
    
    public var isLogged: Bool {
        didSet {
            Config.isLogged = self.isLogged
        }
    }
	
	public var palette: Palette? {
		didSet {
			Config.Palette = self.palette
		}
	}
	
	public var placeholder: UIImage? {
		didSet {
			Config.placeholder = self.placeholder
		}
	}
    
    public var blockedContentView: StatusView? {
        didSet {
            Config.blockedContentView = self.blockedContentView
        }
    }
	
    public var loadingView: StatusView? {
        didSet {
            Config.loadingView = self.loadingView
        }
    }
    
    public var contentListBackgroundColor: UIColor? {
        didSet {
            Config.contentListBackgroundColor = self.contentListBackgroundColor
        }
    }
    
    public var contentListMarginsColor: UIColor? {
        didSet {
            Config.contentListMarginsColor = self.contentListMarginsColor
        }
    }
    
	public var noContentView: StatusView? {
		didSet {
			Config.noContentView = self.noContentView
		}
	}
	
    public var noSearchResultView: StatusView? {
        didSet {
            Config.noSearchResultView = self.noSearchResultView
        }
    }
    
    public var errorViewInstantiator: ErrorView.Type? {
        didSet {
            Config.errorView = self.errorViewInstantiator
        }
    }
    
    public var languageCode: String? {
        didSet {
            Session.shared.languageCode = self.languageCode
        }
    }
    
	internal let wireframe = Wireframe(
		application: Application()
	)
    
	override init() {
		self.logLevel = .none
		LogManager.shared.appName = "OCM"
		self.host = ""
		self.placeholder = nil
        self.isLogged = false
        
        super.init()
        self.loadFonts()
	}
	
	/**
	Retrieve the section list
	
	Use it to build a dynamic menu in your app
	
	- returns: Dictionary of sections to be represented
	
	- Since: 1.0
	*/
	public func menus(completionHandler: @escaping (_ succeed: Bool, _ menus: [Menu], _ error: NSError?) -> Void) {
		MenuCoordinator(
            sessionInteractor: SessionInteractor(
                session: Session.shared,
                orchextra: OrchextraWrapper.shared
            )
        ).menus(completion:
			completionHandler)
	}
	
    /**
     Retrieve a SearchViewController
     
     Use it to show and search contents
     
     - returns: OrchextraViewController
     
     - Since: 1.0
     */
    
    public func searchViewController() -> OrchextraViewController? {
        return OCM.shared.wireframe.contentList()
    }
    
	/**
	Run the action with an id
	
	Use it to run actions programatically (for example it can be triggered with an application url scheme)
	
	- parameter id: The id of the action
	
	- Since: 1.0
	*/
    public func openAction(with id: String, completion: @escaping (UIViewController?) -> Void) {
        let actionInteractor = ActionInteractor(
            dataManager: ActionDataManager(
                storage: Storage.shared,
                elementService: ElementService()
            )
        )
        actionInteractor.action(with: id, completion: { action, _ in
            if let action = action {
                switch action {
                case is ActionYoutube:
                    completion(action.view())
                default:
                    completion(self.wireframe.provideMainComponent(with: action))
                }
            } else {
                completion(nil)
            }
        })
	}
	
	/**
	Retrieve the content list view controller
	
	Use it to present this view to your users
	
	- returns: ViewController to be presented
	
	- Since: 1.0
	*/
	public func notificationReceived(_ notification: [AnyHashable : Any]) {
		PushInteractor().pushReceived(notification)
	}
    
    /**
     Updates local storage information
     
     Use it set it in web view content that requires login access
     
     - Since: 1.0
     */
    public func updateLocalStorage(localStorage: [AnyHashable : Any]?) {
        Session.shared.localStorage = localStorage
    }
    
	public func didUpdate(accessToken: String?) {
		self.delegate?.didUpdate(accessToken: accessToken)
	}
	
	
	// MARK: - Private Helpers
	
    private func loadFonts() {
        UIFont.loadSDKFont(fromFile: "gotham-ultra.ttf")
        UIFont.loadSDKFont(fromFile: "gotham-medium.ttf")
        UIFont.loadSDKFont(fromFile: "gotham-light.ttf")
        UIFont.loadSDKFont(fromFile: "gotham-book.ttf")
    }
	
}

//swiftlint:disable class_delegate_protocol
public protocol OCMDelegate {
	func customScheme(_ url: URLComponents)
    func requiredUserAuthentication()
    func didUpdate(accessToken: String?)
    func showPassbook(error: PassbookError)
    func userDidOpenContent(with id: String)
}
//swiftlint:enable class_delegate_protocol

public protocol OCMAnalytics {
    func track(with info: [String: Any?])
}
