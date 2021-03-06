//
//  ViewController.swift
//  DemoApp
//
//  Created by Alejandro Jiménez Agudo on 30/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import OCMSDK
import GIGLibrary
import Orchextra


class ViewController: UIViewController, OCMDelegate {
	
	let ocm = OCM.shared
	let orchextra: Orchextra = Orchextra.sharedInstance()
	var menu: [Section]?
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.ocm.delegate = self
		self.ocm.analytics = self
		self.ocm.host = "https://" + InfoDictionary("OCM_HOST")
		self.ocm.logLevel = .debug
		self.ocm.loadingView = LoadingView()
		self.ocm.noContentView = NoContentView()
		self.ocm.errorViewInstantiator = MyErrorView.self
		self.ocm.isLogged = false
		self.ocm.blockedContentView = BlockedView()
		self.ocm.placeholder = UIImage(named: "placeholder")
		self.ocm.countryCode = InfoDictionary("OCM_COUNTRY")
		
		Orchextra.logLevel(.all)
		let orchextraHost = "https://" + InfoDictionary("ORCHEXTRA_HOST")
		ORCSettingsDataManager().setEnvironment(orchextraHost)
		let orchextraApikey = InfoDictionary("ORCHEXTRA_APIKEY")
		let orchextraApisecret = InfoDictionary("ORCHEXTRA_APISECRET")
		
		self.orchextra.setApiKey(orchextraApikey, apiSecret: orchextraApisecret) { success, error in
			if success {
				self.ocm.menus { succeed, menus, _ in
					if succeed {
						if let menu: Menu = menus.first {
							self.menu = menu.sections
							self.tableView.reloadData()
						}
					}
				}
			} else {
				LogError(error as NSError?)
			}
		}
		
	}
	
	
	// MARK - OCMDelegate
	
	func sessionExpired() {
		print("Session expired")
	}
	
	func customScheme(_ url: URLComponents) {
		print("CUSTOM SCHEME: \(url)")
		UIApplication.shared.openURL(url.url!)
	}
	
	func requiredUserAuthentication() {
		print("User authentication needed it.")
		OCM.shared.isLogged = true
	}
	
	func didUpdate(accessToken: String?) {
		print("Access token: \(accessToken)")
	}
	
	func userDidOpenContent(with id: String) {
		print("Did open content \(id)")
	}
	
	func showPassbook(error: PassbookError) {
		var message: String = ""
		switch error {
		case .error(_):
			message = "Lo sentimos, ha ocurrido un error inesperado"
			break
			
		case .unsupportedVersionError(_):
			message = "Su dispositivo no es compatible con passbook"
			break
		}
		
		let actionSheetController: UIAlertController = UIAlertController(title: "Title", message: message, preferredStyle: .alert)
		let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { _ -> Void in
		}
		actionSheetController.addAction(cancelAction)
		self.present(actionSheetController, animated: true, completion: nil)
	}
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.menu?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
		
		let section = self.menu?[indexPath.row]
		
		cell?.textLabel?.text = section?.name
		
		return cell!
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		let section = self.menu?[indexPath.row]
		
		if let view = section?.openAction() {
			view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 300, right: 0)
			self.show(view, sender: true)
		}
	}
}

extension ViewController: OCMAnalytics {
	
	func track(with info: [String: Any?]) {
		print(info)
	}
}

class LoadingView: StatusView {
	func instantiate() -> UIView {
		let loadingView = UIView(frame: CGRect.zero)
		loadingView.addSubviewWithAutolayout(UIImageView(image: #imageLiteral(resourceName: "loading")))
		loadingView.backgroundColor = .blue
		return loadingView
	}
}

class BlockedView: StatusView {
	func instantiate() -> UIView {
		let blockedView = UIView(frame: CGRect.zero)
		blockedView.addSubviewWithAutolayout(UIImageView(image: UIImage(named: "color")))
		
		let imageLocker = UIImageView(image: UIImage(named: "wOAH_locker"))
		imageLocker.translatesAutoresizingMaskIntoConstraints = false
		imageLocker.center = blockedView.center
		blockedView.addSubview(imageLocker)
		blockedView.alpha = 0.8
		addConstraintsIcon(icon: imageLocker, view: blockedView)
		
		return blockedView
	}
	
	func addConstraintsIcon(icon: UIImageView, view: UIView) {
		
		let views = ["icon": icon]
		
		view.addConstraint(NSLayoutConstraint.init(
			item: icon,
			attribute: .centerX,
			relatedBy: .equal,
			toItem: view,
			attribute: .centerX,
			multiplier: 1.0,
			constant: 0.0)
		)
		
		view.addConstraint(NSLayoutConstraint.init(
			item: icon,
			attribute: .centerY,
			relatedBy: .equal,
			toItem: view,
			attribute: .centerY,
			multiplier: 1.0,
			constant: 0.0)
		)
		
		view.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "H:[icon(65)]",
			options: .alignAllCenterY,
			metrics: nil,
			views: views))
		
		view.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "V:[icon(65)]",
			options: .alignAllCenterX,
			metrics: nil,
			views: views))
	}
}

class NoContentView: StatusView {
	func instantiate() -> UIView {
		let loadingView = UIView(frame: CGRect.zero)
		loadingView.addSubviewWithAutolayout(UIImageView(image: #imageLiteral(resourceName: "DISCOVER MORE")))
		loadingView.backgroundColor = .gray
		return loadingView
	}
}

class MyErrorView: UIView, ErrorView {
	
	var retryBlock: (() -> Void)?
	public func view() -> UIView {
		return self
	}
	
	public func set(retryBlock: @escaping () -> Void) {
		self.retryBlock = retryBlock
	}
	
	public func set(errorDescription: String) {
		
	}
	
	static func instantiate() -> ErrorView {
		let errorView = MyErrorView(frame: CGRect.zero)
		let button = UIButton(type: .system)
		button.setTitle("Retry", for: .normal)
		button.addTarget(errorView, action: #selector(didTapRetry), for: .touchUpInside)
		errorView.addSubviewWithAutolayout(button)
		errorView.backgroundColor = .gray
		return errorView
	}
	
	func didTapRetry() {
		retryBlock?()
	}
}
