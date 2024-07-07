//
//  ChatViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/22.
//

import UIKit
import RxSwift
import PhotosUI
import MessageKit
import InputBarAccessoryView

final class ChatViewController: MessagesViewController {
    
    private var loadingView: UIView!
    var activityIndicator: UIActivityIndicatorView!
    private var sideMenuView: SideMenuView
    private let sideMenuBackgroundView = UIView()
    private var messages: [Message] = []
    private lazy var customInputBar = ChatInputBar(status: .opened)
    private var imagePickerController: PHPickerViewController!
    private lazy var chatInformationView = ChatInformationView(type: .caution)
    private let chatMessageEmptyView = EmptyView(type: .chat)
    
    private var viewModel: ChatViewModel?
    private var disposeBag = DisposeBag()
    
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        self.sideMenuView = SideMenuView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConfig()
        setUI()
        setConstraint()
        bind()
        showLoadingView()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(deleteSideMenu), name: NSNotification.Name.removeSideMenu, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(recievedMessage), name: NSNotification.Name.recievedMessage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(findAllMessages), name: NSNotification.Name.findAllMessages, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            hideSideMenu()
        }
    }
    
    private func setConfig() {
        let chatRoom = viewModel?.getRoomInfo()
        
        if let isClosed = chatRoom?.isClosed, isClosed {
            self.chatInformationView = ChatInformationView(type: .closed)
            self.customInputBar = ChatInputBar(status: .closed)
        } else {
            var imagePickerConfig = PHPickerConfiguration()
            imagePickerConfig.selectionLimit = 1
            imagePickerController = PHPickerViewController(configuration: imagePickerConfig)
            imagePickerController.delegate = self
        }
        
        let menuButton = UIBarButtonItem(image: UIImage(named: "sideMenu"), style: .plain, target: self, action: #selector(showSideMenu))
        self.navigationItem.rightBarButtonItem = menuButton
        
        view.backgroundColor = AppColor.thinGrayBackground.color
        messagesCollectionView.backgroundColor = AppColor.thinGrayBackground.color
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.contentInset.top = 37
        messagesCollectionView.scrollIndicatorInsets = messagesCollectionView.contentInset
        messagesCollectionView.register(ChatDateHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        
        inputBarType = .custom(customInputBar)
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnInputBarHeightChanged = true
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.setMessageIncomingMessagePadding(UIEdgeInsets(top: 4, left: 10, bottom: 0, right: 0))
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageOutgoingMessagePadding(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        layout?.setMessageIncomingAvatarPosition(.init(horizontal: .natural, vertical: .messageCenter))
        layout?.setMessageIncomingAccessoryViewSize(.init(width: 48, height: 12))
        layout?.setMessageOutgoingAccessoryViewSize(.init(width: 48, height: 12))
        layout?.setMessageIncomingAccessoryViewPadding(.init(left: 6, right: 0))
        layout?.setMessageOutgoingAccessoryViewPadding(.init(left: 0, right: -6))
        
        layout?.setMessageIncomingAccessoryViewPosition(.messageBottom)
        layout?.setMessageOutgoingAccessoryViewPosition(.messageBottom)
        
        layout?.attributedTextMessageSizeCalculator.incomingMessageLabelInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        layout?.attributedTextMessageSizeCalculator.outgoingMessageLabelInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        additionalBottomInset = 4
        
        sideMenuBackgroundView.backgroundColor = AppColor.black.color.withAlphaComponent(0.5)
        
        loadingView = UIView(frame: view.bounds)
        loadingView.backgroundColor = .clear
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = loadingView.center
        activityIndicator.startAnimating()
        
        loadingView.addSubview(activityIndicator)
        
        chatMessageEmptyView.isHidden = true
        chatMessageEmptyView.isUserInteractionEnabled = false
        sideMenuBackgroundView.isHidden = true
    }
    
    private func setUI() {
        view.addSubview(chatInformationView)
        view.addSubview(chatMessageEmptyView)
        self.navigationController?.view.addSubview(sideMenuBackgroundView)
        self.navigationController?.view.addSubview(sideMenuView)
    }
    
    private func setConstraint() {
        
        chatInformationView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(37)
        }
        
        chatMessageEmptyView.snp.makeConstraints { make in
            make.top.equalTo(chatInformationView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        sideMenuBackgroundView.frame = self.navigationController?.view.bounds ?? view.bounds
        
        let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
        
        sideMenuView.snp.remakeConstraints { make in
            make.top.equalTo(navigationBarHeight)
            make.leading.equalTo(self.view.frame.maxX + 10)
            make.bottom.equalToSuperview()
        }
    }
    
    private func bind() {
        let input = ChatViewModel.Input()
        _ = viewModel?.transform(input: input)
        
        customInputBar.getImageButtonObservable().subscribe({ [weak self] _ in
            guard let self = self else { return }
            self.imagePickerController.modalPresentationStyle = .formSheet
            self.present(self.imagePickerController, animated: true, completion: nil)
        })
        .disposed(by: disposeBag)
        
        customInputBar.sendButton.rx.tap
            .map { [weak self] _ in
                self?.customInputBar.inputTextView.text ?? ""
            }.subscribe(onNext: { [weak self] messageText in
                guard let self = self else { return }
                if messageText.isEmpty {
                    return
                } else {
                    if let roomId = viewModel?.getRoomId() {
                        self.viewModel?.sendMessage(parm: CreateMessageParm(roomId: roomId, content: messageText))
                    }
                    self.customInputBar.inputTextView.text = ""
                }
            })
            .disposed(by: disposeBag)
        
        sideMenuBackgroundView.rx.tapGesture().skip(1).subscribe({ [weak self] _ in
            self?.hideSideMenu()
        })
        .disposed(by: disposeBag)
        
        viewModel?.subscribePresignedUrl()
    }
    
    @objc
    private func findAllMessages(_ data: NSNotification) {
        if let datas = data.userInfo?["messages"] as? [Message] {
            messages = datas
            messagesCollectionView.reloadData()
            messagesCollectionView.scrollToLastItem(animated: false)
        } else {
            chatMessageEmptyView.isHidden = false
        }
        hideLoadingView(1)
    }
    
    @objc
    private func recievedMessage(_ data: NSNotification) {
        let message = data.userInfo!["messages"] as! Message
        messages.append(message)
       
        messagesCollectionView.reloadData()
        
        if !messagesCollectionView.isDragging {
            messagesCollectionView.scrollToLastItem(animated: false)
        }
    }
    
    @objc
    private func reloadChatRoom(_ data: NSNotification) {
        guard let roomId = data.userInfo?["roomId"] as? String else {
            return
        }
        
        // 개인 채팅방일 경우
        // 밥약의 경우, 자신이 나가지 않는 이상 방이 사라지지 않음
        if let isPersonal = self.viewModel?.getRoomInfo().isPrivate {
            if self.viewModel?.getRoomId() == roomId {
                AlertManager.shared.showLeaveRoom(self) { isLeave in
                    if isLeave {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    @objc
    private func showSideMenu() {
        sideMenuView.initSideMenuView()
        customInputBar.inputTextView.resignFirstResponder()

        let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.sideMenuBackgroundView.isHidden = false
            self.sideMenuView.snp.remakeConstraints { make in
                make.top.equalTo(navigationBarHeight)
                make.leading.equalTo(55)
                make.bottom.equalToSuperview()
                make.width.equalTo(self.view.frame.width - 55)
            }
            
            self.navigationController?.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func hideSideMenu() {
        
        let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.sideMenuBackgroundView.isHidden = true
            self.sideMenuView.snp.remakeConstraints { make in
                make.top.equalTo(navigationBarHeight)
                make.leading.equalTo(self.view.frame.maxX + 10)
                make.bottom.equalToSuperview()
            }
            
            self.navigationController?.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func deleteSideMenu() {
        sideMenuBackgroundView.isHidden = true
        hideSideMenu()
    }
    
    private func showLoadingView() {
        view.addSubview(loadingView)
        UIApplication.shared.keyWindow?.isUserInteractionEnabled = false
    }
    
    private func hideLoadingView(_ interval: CGFloat) {
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.loadingView.removeFromSuperview()
            UIApplication.shared.keyWindow?.isUserInteractionEnabled = true
        }
    }
    
    deinit {
        viewModel = nil
        disposeBag = DisposeBag()
        sideMenuView.removeFromSuperview()
        navigationController?.view
            .subviews
            .forEach { ($0 as? SideMenuView)?.removeFromSuperview() }
        NotificationCenter.default.removeObserver(self)
    }
}

extension ChatViewController: MessagesDataSource {
    
    var currentSender: MessageKit.SenderType {
        let nickname: String = UserDefaults.standard.getUserInfo(.nickname) ?? ""
        let profilePicture: String = UserDefaults.standard.getUserInfo(.profilePicture) ?? ""
        return Sender(senderId: nickname, displayName: nickname, profilePicture: profilePicture)
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messages[indexPath.section].sender.displayName == messages[indexPath.section - 1].sender.displayName
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messages.count else {
            return false
        }
        return messages[indexPath.section].sender.displayName == messages[indexPath.section + 1].sender.displayName
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        if messages.count > 0 {
            self.chatMessageEmptyView.isHidden = true
        } else {
            self.chatMessageEmptyView.isHidden = false
        }
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isFromCurrentSender(message: message) || isPreviousMessageSameSender(at: indexPath) {
            return nil
        } else {
            let fontMetrics = UIFontMetrics(forTextStyle: .body)
            return NSAttributedString(string: message.sender.displayName, attributes: [.font: fontMetrics.scaledFont(for: AppFont.shared.getBoldFont(size: 10)), .foregroundColor: AppColor.black.color])
        }
    }

    func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        if shouldDisplayTime(at: indexPath) {
            if let timeLabel = accessoryView.subviews.first as? UILabel {
                timeLabel.text = messages[indexPath.section].sentDate.toChatTime
            } else {
                let timeLabel = UILabel()
                let fontMetrics = UIFontMetrics(forTextStyle: .body)
                timeLabel.text = messages[indexPath.section].sentDate.toChatTime
                timeLabel.font = fontMetrics.scaledFont(for: AppFont.shared.getBoldFont(size: 12))
                timeLabel.textColor = AppColor.grayText.color
                accessoryView.addSubview(timeLabel)
                timeLabel.snp.makeConstraints { $0.edges.equalToSuperview() }
            }
        } else {
            accessoryView.subviews.forEach { $0.removeFromSuperview() }
        }
    }
    
    private func shouldDisplayTime(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messages.count else {
            return true
        }
        
        let currentMessage = messages[indexPath.section]
        let nextMessage = messages[indexPath.section + 1]
        
        return currentMessage.sender.displayName != nextMessage.sender.displayName
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if let imageUrl = messages[indexPath.section].fileUrl, !imageUrl.isEmpty {
            DispatchQueue.main.async {
                imageView.loadImageFromUrl(url: URL(string: imageUrl), isDownSampling: false)
            }
        }
    }
}

extension ChatViewController: MessagesLayoutDelegate {
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isPreviousMessageSameSender(at: indexPath) ? 0 : 16
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if isPreviousMessageSameSender(at: indexPath) {
            avatarView.isHidden = true
        } else {
            let imageUrl = messages[indexPath.section].user.profilePicture
            avatarView.loadImageFromUrl(url: URL(string: imageUrl))
            avatarView.setCorner(radius: 5)
            avatarView.backgroundColor = .clear
            avatarView.isHidden = false
        }
    }
    
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        if section - 1 >= 0 {
            let currDay = messages[section].sentDate
            let calendar = Calendar.current
            let prevDay = messages[section - 1].sentDate
            if prevDay < currDay && calendar.component(.day, from: prevDay) < calendar.component(.day, from: currDay) {
                return CGSize(width: messagesCollectionView.bounds.width, height: 40)
            }
        } else if section == 0 {
            return CGSize(width: messagesCollectionView.bounds.width, height: 40)
        }
        
        return .zero
    }
}

extension ChatViewController: MessagesDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? AppColor.purple.color : AppColor.white.color
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? AppColor.white.color : AppColor.black.color
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .custom { view in
            view.layer.cornerRadius = 10
            view.clipsToBounds = true
        }
    }
    
    func messageHeaderView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView {
        
        let header = messagesCollectionView.dequeueReusableHeaderView(ChatDateHeaderView.self, for: indexPath)
        let currDay = messages[indexPath.section].sentDate
        let calendar = Calendar.current
        let attributedText = NSAttributedString (
            string: currDay.toChatDateTime,
            attributes: [
                NSAttributedString.Key.font: AppFont.shared.getRegularFont(size: 10),
                NSAttributedString.Key.foregroundColor: AppColor.black.color,
                NSAttributedString.Key.backgroundColor: AppColor.chatDate.color
            ])
        
        if indexPath.section - 1 >= 0 {
            let prevDay = messages[indexPath.section - 1].sentDate
            if prevDay < currDay && calendar.component(.day, from: prevDay) < calendar.component(.day, from: currDay) {
                header.setup(with: attributedText)
                return header
            }
        } else if indexPath.section == 0 {
            header.setup(with: attributedText)
            return header
        }
        
        return header
    }
}

extension ChatViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                
                guard let image = reading as? UIImage,
                      error == nil
                else { return }
                
                DispatchQueue.main.async {
                    AlertManager.shared.showSendImageMessage(picker) { isSent in
                        if isSent {
                            result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.image") { [weak self] url, _ in
                                guard let fileURL = url else { return }
                                let fileExtension = fileURL.pathExtension.lowercased()
                                let imageExtension = ImageExtension(rawValue: fileExtension)
                                if let type = imageExtension {
                                    self?.viewModel?.postToImagePresignedUrl(image: image, imageType: type.rawValue)
                                    DispatchQueue.main.async {
                                        picker.dismiss(animated: true) {
                                            self?.messagesCollectionView.scrollToLastItem()
                                        }
                                    }
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                picker.dismiss(animated: true)
                            }
                        }
                    }
                }
            }
        }
        
        if results.isEmpty {
            DispatchQueue.main.async {
                picker.dismiss(animated: true)
            }
            return
        }
    }
}
