//
//  ImageMediaItem.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/25.
//

import MessageKit
import UIKit

// MARK: - 채팅 Placeholder Image 요청

struct ImageMediaItem: MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage) {
        self.image = image
        let screenWidth = UIScreen.main.bounds.width
        self.size = CGSize(width: screenWidth / 2, height: screenWidth / 2)
        self.placeholderImage = UIImage()
    }
    
    init(url: URL?) {
        self.url = url
        let screenWidth = UIScreen.main.bounds.width
        self.size = CGSize(width: screenWidth / 2, height: screenWidth / 2)
        self.placeholderImage = UIImage()
    }
}
