//
//  LayoutFactory.swift
//  OCM
//
//  Created by Sergio López on 14/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

struct LayoutFactory {
    
    // MARK: - PUBLIC
    
    func layout(forJSON json: JSON) -> LayoutDelegate {

        let layoutType: Layout = json["name"]?.toString() == "carousel" ? .carousel : .mosaic
        
        switch layoutType {
        case .mosaic:
            guard let patternJSON = json["pattern"] else {
                let defaultSizePattern = [CGSize(width: 1, height: 1)]
                return MosaicLayout(sizePattern: defaultSizePattern)
            }
            let pattern = self.pattern(forJSON: patternJSON)
            return MosaicLayout(sizePattern: pattern)
        case .carousel:
            return CarouselLayout()
        }
    }
    
    // MARK: - PRIVATE
    
    private func pattern(forJSON json: JSON) -> [CGSize] {
        
        let sizes = json.flatMap { (patternJson) -> CGSize? in
            
            guard let rows = patternJson["row"]?.toInt() else { return nil }
            guard let columns = patternJson["column"]?.toInt() else { return nil }

            return CGSize(width: CGFloat(rows), height: CGFloat(columns))
        }
        return sizes
    }
}
