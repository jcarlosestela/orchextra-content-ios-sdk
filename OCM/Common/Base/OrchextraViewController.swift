//
//  OrchextraViewController.swift
//  OCM
//
//  Created by Sergio López on 26/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

public class OrchextraViewController: UIViewController {
    
    // MARK: - PUBLIC
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    public var contentInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    public func filter(byTags: [String]) {
    }
    
    public func search(byString: String) {
    }
    
    public func showInitialContent() {
    }
}
