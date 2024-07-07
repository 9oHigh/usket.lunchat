//
//  ChatInputBar.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/26.
//

import UIKit
import InputBarAccessoryView
import RxSwift

enum ChatRoomStatus {
    case opened
    case closed
}

final class ChatInputBar: InputBarAccessoryView {
    
    private let chatRoomStatus: ChatRoomStatus
    private let photoButton = InputBarButtonItem()
    private let topLineVIew = UIView()
    
    init(status: ChatRoomStatus) {
        self.chatRoomStatus = status
        super.init(frame: .zero)
        setConfig()
        setConstraint()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        maxTextViewHeight = inputTextView.frame.height
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setConfig() {
        if chatRoomStatus == .closed {
            separatorLine.height = 1
            padding = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
            
            inputTextView.placeholder = "대화가 종료된 방입니다"
            inputTextView.placeholderTextColor = AppColor.deepGrayText.color
            inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
            inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
            inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 12, right: 0)
            inputTextView.layer.borderColor = AppColor.textFieldBorder.color.cgColor
            inputTextView.isUserInteractionEnabled = false
            
            inputTextView.layer.borderWidth = 1.0
            inputTextView.layer.cornerRadius = 20
            inputTextView.layer.masksToBounds = true
            inputTextView.backgroundColor = AppColor.textField.color

            setStackViewItems([sendButton, InputBarButtonItem.fixedSpace(2)], forStack: .right, animated: false)
            
            sendButton.title = nil
            sendButton.setImage(UIImage(named: "chatBlock"), for: .normal)
            sendButton.imageView?.contentMode = .scaleAspectFit
            sendButton.setSize(CGSize(width: 24, height: 24), animated: false)
            middleContentViewPadding.right = -44.5
            middleContentViewPadding.left = 12
        } else {
            photoButton.setSize(CGSize(width: 36, height: 36), animated: false)
            photoButton.setImage(#imageLiteral(resourceName: "photo").withRenderingMode(.alwaysTemplate), for: .normal)
            photoButton.imageView?.contentMode = .scaleAspectFit
            photoButton.tintColor = AppColor.black.color
            
            separatorLine.height = 1
            padding = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
            
            inputTextView.placeholder = nil
            inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
            inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
            inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 12, right: 0)
            
            inputTextView.layer.borderColor = AppColor.textFieldBorder.color.cgColor
            inputTextView.layer.borderWidth = 1.0
            inputTextView.layer.cornerRadius = 20
            inputTextView.layer.masksToBounds = true
            inputTextView.backgroundColor = AppColor.textField.color
            
            setLeftStackViewWidthConstant(to: 38, animated: false)
            setRightStackViewWidthConstant(to: 38, animated: false)
            
            setStackViewItems([photoButton], forStack: .left, animated: false)
            setStackViewItems([sendButton, InputBarButtonItem.fixedSpace(2)], forStack: .right, animated: false)
            
            sendButton.title = nil
            sendButton.setImage(UIImage(named: "chatSend"), for: .normal)
            sendButton.imageView?.contentMode = .scaleAspectFit
            sendButton.setSize(CGSize(width: 23.4, height: 23.4), animated: false)
            
            middleContentViewPadding.right = -38
            middleContentViewPadding.left = 12
            shouldAnimateTextDidChangeLayout = false
        }
        
        shouldManageSendButtonEnabledState = false
        sendButton.isEnabled = true
    }

    private func setConstraint() {
        sendButton.snp.updateConstraints { make in
            make.top.equalTo(2)
            make.centerY.equalTo(inputTextView.snp.centerY)
            make.bottom.equalTo(-2)
        }
    }
    
    func getImageButtonObservable() -> Observable<Void> {
        return photoButton.rx.tap.asObservable()
    }
}
