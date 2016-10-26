//
//  MainContentViewController.swift
//  OCM
//
//  Created by Judith Medina on 24/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class MainContentViewController: UIViewController, PMainContent, UIScrollViewDelegate {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var presenter: MainPresenter?
    var previewInteractionController: PreviewInteractionController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        
        self.presenter?.viewIsReady()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Events
    
    
    @IBAction func didTap(_ backButton: UIButton) {
        self.hide()
    }
    
    // MARK: PMainContent
    
    func show(preview: Preview?, action: Action) {
        
        var contentBelow: Bool = false
        
        if (action.view()) != nil {
            contentBelow = true
        }
        
        if let previewView = preview?.display(), let preview = preview {
            self.stackView.addArrangedSubview(previewView)
            self.previewInteractionController = PreviewInteractionController(scroll: self.scrollView, previewView: previewView, preview: preview, existContentBelow: contentBelow) {
                
                if !contentBelow {
                    action.executable()
                }
            }
        }
        
        if let viewAction = action.view() {
            addChildViewController(viewAction)
            viewAction.didMove(toParentViewController: self)
            self.stackView.addArrangedSubview(viewAction.view)
        }
    }
}