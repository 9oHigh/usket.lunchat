//
//  ChatViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/28.
//

import UIKit
import RxSwift
import RxRelay

final class ChatViewModel: BaseViewModel {
    
    struct Input { }
    struct Output { }
    
    private let chatRoom: ChatRoom
    let photosWithDate = BehaviorSubject<[String: [FileInfo]]>(value: [:])
    let photos = BehaviorSubject<[FileInfo]>(value: [])
    let participantInfo = PublishSubject<[Participant]>()
    
    private let chatUseCase: ChatUseCase
    private let fileUseCase: FileUseCase
    private weak var chatViewDelegate: ChatViewDelegate?
    var disposeBag = DisposeBag()
    
    init(chatRoom: ChatRoom, chatUseCase: ChatUseCase, fileUseCase: FileUseCase, delegate: ChatViewDelegate, _ initMessage: String? = nil) {
        self.chatRoom = chatRoom
        self.chatUseCase = chatUseCase
        self.fileUseCase = fileUseCase
        self.chatViewDelegate = delegate
        
        if let initMessage = initMessage {
            self.initializeMessage(initMessage: initMessage)
        }
        
        self.findAllMessages()
        
        NotificationCenter.default.addObserver(self, selector: #selector(leaveRoom), name: NSNotification.Name.leaveRoom, object: nil)
    }

    func transform(input: Input) -> Output {
        return Output()
    }
    
    func getRoomInfo() -> ChatRoom {
        return self.chatRoom
    }
    
    func getRoomId() -> String {
        return chatRoom.id
    }
    
    func subscribePresignedUrl() {
        fileUseCase.fileId.subscribe({ [weak self] id in
            guard let self = self,
                  let id = id.element
            else { return }
            self.sendImageMessage(parm: CreateMessageParm(roomId: self.chatRoom.id, content: "사진을 보냈습니다", fileId: id))
        })
        .disposed(by: disposeBag)
    }
    
    func postToImagePresignedUrl(image: UIImage, imageType: String) {
        let fileExt = FileExt(fileExt: imageType)
        fileUseCase.createPresignedUrl(image: image, imageType: fileExt)
    }

    deinit {
        disposeBag = DisposeBag()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Chat

extension ChatViewModel {
    
    private func initializeMessage(initMessage: String) {
        let parm = CreateMessageParm(roomId: chatRoom.id, content: initMessage)
        sendMessage(parm: parm)
    }
    
    private func findAllMessages() {
        SocketIOManager.shared.findAllMessages(roomId: chatRoom.id)
    }
    
    func sendMessage(parm: CreateMessageParm) {
        SocketIOManager.shared.sendMessage(parm: parm)
    }
    
    private func sendImageMessage(parm: CreateMessageParm) {
        SocketIOManager.shared.sendImageMessage(parm: parm)
    }
    
    @objc
    private func leaveRoom() {
        SocketIOManager.shared.leaveRoom(roomId: chatRoom.id)
    }
}

// MARK: - Coordinator

extension ChatViewModel {
    
    func showPhotosViewController() {
        guard let filesWithDate = try? photosWithDate.value() else {
            return
        }
        chatViewDelegate?.showPhotosViewController(with: filesWithDate)
    }
    
    func showUserProfile(nickname: String) {
        chatViewDelegate?.showUserProfileView(nickname: nickname)
    }
    
    func exitRoom() {
        if chatRoom.isPrivate {
            chatViewDelegate?.showChatExitRoom(isPrivate: chatRoom.isPrivate)
        } else {
            chatViewDelegate?.showChatExitRoom(isPrivate: false)
        }
    }
}

// MARK: - Side Menu

extension ChatViewModel {

    func fetchRoomInfo() {
        self.chatUseCase.getSpecificChatRoom(id: chatRoom.id)
    }
    
    func subscribeSideMenuInfo() {
        self.chatUseCase.chatRoom.subscribe({ [weak self] chatRoom in
            guard let self = self else { return }
            if let chatRoomInfo = chatRoom.element, let roomInfo = chatRoomInfo {
                self.photosWithDate.onNext(self.organizeFilesByDate(files: roomInfo.files))
                self.photos.onNext(self.organizeFilesByDate(files: roomInfo.files ?? []))
                self.participantInfo.onNext(roomInfo.participants)
            }
        })
        .disposed(by: disposeBag)
    }
    
    private func organizeFilesByDate(files: [FileInfo]?) -> [String: [FileInfo]] {
        
        guard let files = files else { return [:] }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        var filesByDate: [String: [FileInfo]] = [:]
        
        for file in files {
            if let date = dateFormatter.date(from: file.createdAt) {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day], from: date)
                if let dateOnly = calendar.date(from: components) {
                    let formattedDate = dateFormatter.string(from: dateOnly)
                    if var filesArray = filesByDate[formattedDate] {
                        filesArray.append(file)
                        filesByDate[formattedDate] = filesArray
                    } else {
                        filesByDate[formattedDate] = [file]
                    }
                }
            }
        }
        
        var sortedFilesByDate: [String: [FileInfo]] = [:]
        for key in filesByDate.keys.sorted(by: >) {
            sortedFilesByDate[key] = filesByDate[key]
        }
            
        return sortedFilesByDate
    }
    
    private func organizeFilesByDate(files: [FileInfo]) -> [FileInfo] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        let sortedFiles = files.sorted {
            guard let date1 = dateFormatter.date(from: $0.createdAt),
                  let date2 = dateFormatter.date(from: $1.createdAt) else {
                return false
            }
            return date1 > date2
        }

        return sortedFiles
    }
}
