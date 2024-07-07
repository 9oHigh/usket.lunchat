//
//  ChatCoordinator.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/03.
//

import UIKit
import RxSwift

final class ChatCoordinator: Coordinator {

    var delegate: CoordinatorDelegate?
    var navigationController: LunchatNavigationController
    var childCoordinators = [Coordinator]()
    var type: CoordinatorType = .chat
    private var disposeBag = DisposeBag()
    
    init(_ navigationController: LunchatNavigationController) {
        self.navigationController = navigationController
        NotificationCenter.default.addObserver(self, selector: #selector(leaveRoomSuccess), name: NSNotification.Name.leaveRoomSuccess, object: nil)
    }
    
    func start() {
        let chatMainViewController = getChatMainViewController()
        navigationController.pushViewController(chatMainViewController, animated: false)
        navigationController.visibleViewController?.unSetNavBackButton(title: "채팅")
        establishConnection()
    }

    @objc
    private func leaveRoomSuccess() {
        NotificationCenter.default.post(name: NSNotification.Name.removeSideMenu, object: nil)
        navigationController.popViewController(animated: true)
    }
}

// MARK: - Chat

extension ChatCoordinator: ChatViewDelegate, ChatMainViewDelegate {
    
    func showAppointmentChatViewController(chatRoom: ChatRoom) {
        let chatViewController = getChatViewController(chatRoom: chatRoom)
        navigationController.visibleViewController?.setNavBackButton(title: "")
        navigationController.pushViewController(chatViewController, animated: true)
        
        var chatRoomName: String = ""
        for index in 0 ..< chatRoom.participants.count {
            if index == chatRoom.participants.count - 1 {
                chatRoomName += "\(chatRoom.participants[index].nickname)"
            } else {
                chatRoomName += "\(chatRoom.participants[index].nickname), "
            }
        }
        
        navigationController.visibleViewController?.title = chatRoomName
    }
    
    func showPersonalChatViewController(chatRoom: ChatRoom, _ initMessage: String? = nil) {
        let chatViewController = getChatViewController(chatRoom: chatRoom, initMessage)
        navigationController.visibleViewController?.setNavBackButton(title: "")
        navigationController.pushViewController(chatViewController, animated: true)
        
        let nickname = UserDefaults.standard.getUserInfo(.nickname)
        let partner = chatRoom.participants.filter{ $0.nickname != nickname }
        navigationController.visibleViewController?.title = partner.first?.nickname
    }
    
    func showPhotosViewController(with imageDatas: [String : [FileInfo]]) {
        let viewController = SideMenuPhotosViewController(filesWithDate: imageDatas, delegate: self)
        navigationController.visibleViewController?.setNavBackButton(title: "사진")
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showPhotoDetail(photoUrl: String, date: String) {
        let viewController = PhotoDetailViewController(photoUrl: photoUrl, date: date)
        navigationController.visibleViewController?.setNavBackButton(title: "사진")
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showChatExitRoom(isPrivate: Bool = false) {
        let viewController = ChatExitRoom()
        viewController.modalPresentationStyle = .overFullScreen

        viewController.getCancelButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.getCheckButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true) {
                if isPrivate {
                    NotificationCenter.default.post(name: NSNotification.Name.leaveRoom, object: nil)
                } else {
                    self?.showChatExitRoomImpossible()
                }
            }
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showChatExitRoomImpossible() {
        let viewController = ChatExitRoomImpossible()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getButtonObservable().subscribe(onNext: {[weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showUserProfileView(nickname: String) {
        let viewController = getProfileBottomSheet(nickname: nickname)
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getViewTapGesture().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        navigationController.present(viewController, animated: false)
    }
}

// MARK: - Profile

extension ChatCoordinator: ProfileBottomSheetDelegate {
    // Ticket
    func showUseTicketView(nickname: String, viewModel: ProfileBottomSheetViewModel) {
        let viewController = UseNoteTicket()
        viewController.modalPresentationStyle = .overFullScreen
        viewController.setUserNickname(nickname: nickname)
        
        viewController.getCancelButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.getCheckButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewModel.useTicket(toNickname: nickname, initMessage: viewController?.getMessage()) { [weak self] isSuceess in
                if isSuceess {
                    viewController?.view.alpha = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        viewController?.dismiss(animated: true)
                    }
                } else {
                    viewController?.dismiss(animated: true)
                }
            }
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showUseTicketFailure() {
        let viewController = UseNoteTicketFailure()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getButtonObservable().subscribe(onNext: { [weak self] _ in
            viewController.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showEmptyTicket() {
        let viewController = EmptyNoteTicket()
        viewController.modalPresentationStyle = .overFullScreen
        lazy var shopViewController = getShopViewController()

        viewController.getCheckButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true) {
                self?.navigationController.visibleViewController?.setNavBackButton(title: "상품")
                self?.navigationController.pushViewController(shopViewController, animated: true)
            }
        })
        .disposed(by: disposeBag)
        
        viewController.getCancelButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }

    // Report
    func showReportUserView(nickname: String, viewModel: ProfileBottomSheetViewModel) {
        let viewController = ReportBottomSheet(targetUser: nickname)
        viewController.modalPresentationStyle = .overFullScreen

        viewController.getReportButtonObservable().subscribe(onNext: { [weak self, weak viewController] reason in
            if let available =  viewController?.isAvailableReportReason(), available {
                viewModel.reportUser(nickname: nickname, reason: reason)
                viewController?.dismiss(animated: true)
            } else {
                viewController?.dismiss(animated: true) {
                    self?.showReportFailure()
                }
            }
        })
        .disposed(by: disposeBag)
        
        viewController.getCancelButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        navigationController.present(viewController, animated: false)
    }
    
    func showReportSuccess() {
        let viewController = ReportSuccess()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showReportFailure() {
        let viewController = ReportFailure()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }
}

// MARK: - Shop

extension ChatCoordinator: ShopViewDelegate {
    
    func showTicketCreateView(ticket: TicketType, viewModel: PurchaseViewModel) {
        let viewController = NoteTicketCreate()
        viewController.setNoteCount(ticket.rawValue)
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getCheckButtonObservable().subscribe(onNext: { [weak viewController] _ in
            viewModel.currentProductId = ProductId.allCases[ticket.indexPath]
            viewModel.buyProduct(productID: ProductId.allCases[ticket.indexPath].rawValue)
            viewController?.dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name.addLoadingView, object: nil)
            }
        })
        .disposed(by: disposeBag)
        
        viewController.getCancelButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showTicketCreateSuccess() {
        let viewController = NoteTicketCreateSuccess()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showTicketCreateFailure() {
        let viewController = NoteTicketCreateFailure()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }
}
                                
extension ChatCoordinator {
    
    private func getChatMainViewController() -> ChatMainViewController {
        let personalChatViewController = getPersonalChatViewController()
        let appointmentChatViewController = getAppointmentChatViewController()
        let chatMainViewController = ChatMainViewController(viewControllers: [personalChatViewController, appointmentChatViewController])
        return chatMainViewController
    }
    
    private func getPersonalChatViewController() -> PersonalChatViewController {
        let chatRepository = ChatRepository()
        let chatUseCase = ChatUseCase(chatRepository: chatRepository)
        let viewModel = PersonalChatViewModel(useCase: chatUseCase, delegate: self)
        return PersonalChatViewController(viewModel: viewModel)
    }
    
    private func getAppointmentChatViewController() -> AppointmentChatViewController {
        let chatRepository = ChatRepository()
        let chatUseCase = ChatUseCase(chatRepository: chatRepository)
        let viewModel = AppointmentChatViewModel(useCase: chatUseCase, delegate: self)
        return AppointmentChatViewController(viewModel: viewModel)
    }

    
    private func getChatViewController(chatRoom: ChatRoom, _ initMessage: String? = nil) -> ChatViewController {
        let chatRepository = ChatRepository()
        let chatUseCase = ChatUseCase(chatRepository: chatRepository)
        let fileRepository = FileRepository()
        let fileUseCase = FileUseCase(fileRepository: fileRepository)
        let viewModel = ChatViewModel(chatRoom: chatRoom, chatUseCase: chatUseCase, fileUseCase: fileUseCase, delegate: self, initMessage)
        let viewController = ChatViewController(viewModel: viewModel)
        
        return viewController
    }
    
    private func getProfileBottomSheet(nickname: String) -> ProfileBottomSheet {
        let repository = ProfileBottomSheetRepository()
        let useCase = ProfileBottomSheetUseCase(profileBottomSheetRepository: repository)
        let viewModel = ProfileBottomSheetViewModel(nickname: nickname, useCase: useCase, delegate: self)
        return ProfileBottomSheet(viewModel: viewModel)
    }
    
    private func getShopViewController() -> ShopViewController {
        let paymentRepository = PaymentRepository()
        let paymentUseCase = PaymentUseCase(paymentRepository: paymentRepository)
        
        let ticketRepository = TicketRepository()
        let ticketUseCase = TicketUseCase(ticketRepository: ticketRepository)
        
        let purchaseViewModel = PurchaseViewModel(paymentUseCase: paymentUseCase, ticketUseCase: ticketUseCase, delegate: self)
        let purchaseHistoryViewModel = PurchaseHistoryViewModel(useCase: ticketUseCase)
        let useHistoryViewModel = UseHistoryViewModel(useCase: ticketUseCase)
        
        let purchaseViewController = PurchaseViewController(viewModel: purchaseViewModel)
        let purchaseHistoryViewController = PurchaseHistoryViewController(viewModel: purchaseHistoryViewModel)
        let useHistoryViewController = UseHistoryViewController(viewModel: useHistoryViewModel)
        
        let shopViewController = ShopViewController(viewControllers: [purchaseViewController, purchaseHistoryViewController, useHistoryViewController])
        return shopViewController
    }
}

extension ChatCoordinator {
    
    private func establishConnection() {
        SocketIOManager.shared.establishConnection()
    }
}
