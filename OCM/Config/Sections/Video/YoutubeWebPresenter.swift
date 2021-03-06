//
//  YoutubeWebPresenter.swift
//  OCM
//
//  Created by Carlos Vicente on 8/11/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation

protocol YoutubeWebViewPresenterProtocol {
    func viewIsReady(with height: Int, width: Int)
}

protocol YoutubeWebView {
    func load(with htmlString: String)
}

struct YoutubeWebPresenter: YoutubeWebViewPresenterProtocol {
    
    let view: YoutubeWebView
    let interactor: YoutubeWebInteractor
    
    // MARK: Presenter protocol
    
    func viewIsReady(with height: Int, width: Int) {
        
        guard let videoId = self.interactor.videoId else {
            LogWarn("Invalid video id")
            return
        }
        
        let htmlString = self.interactor.formattedEmbeddedHtml(
            height: height,
            width: width,
            videoId: videoId
        )
        
        self.view.load(with: htmlString)
    }
}
