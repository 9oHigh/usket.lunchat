//
//  Message.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/25.
//

import UIKit
import MessageKit

struct Message: MessageType {
    
    var messageId: String = UUID().uuidString
    var image: UIImage?
    var fileUrl: String?
    let content: String
    let sentDate: Date
    let roomId: String
    let sender: SenderType
    let user: Sender
    
    var kind: MessageKind {
        if let image = image {
            let mediaItem = ImageMediaItem(image: image)
            return .photo(mediaItem)
        } else if let fileUrl = fileUrl {
            let mediaItem = ImageMediaItem(url: URL(string: fileUrl))
            return .photo(mediaItem)
        } else {
            let senderNickname = (sender.displayName == UserDefaults.standard.getUserInfo(.nickname))
            let fontMetrics = UIFontMetrics(forTextStyle: .body)
            return .attributedText(NSAttributedString(string: content, attributes: [.font: fontMetrics.scaledFont(for: AppFont.shared.getRegularFont(size: 12)), .foregroundColor: senderNickname ? AppColor.white.color : AppColor.black.color]))
        }
    }
    
    init(content: String, sender: Sender, date: String, roomId: String) {
        self.content = content
        self.sender = sender
        self.user = sender
        self.roomId = roomId
        sentDate = date.toDate()
    }
    
    init(fileUrl: String, sender: Sender, date: String, roomId: String) {
        self.fileUrl = fileUrl
        self.sender = sender
        self.user = sender
        self.roomId = roomId
        sentDate = date.toDate()
        content = "사진을 보냈습니다."
    }
}

extension Message: Comparable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.messageId == rhs.messageId
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}
