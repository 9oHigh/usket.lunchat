//
//  SearchCoordinator.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/03.
//

import UIKit
import RxSwift

final class SearchCoordinator: Coordinator {
    
    var delegate: CoordinatorDelegate?
    var navigationController: LunchatNavigationController
    var childCoordinators = [Coordinator]()
    var type: CoordinatorType = .search
    private var disposeBag = DisposeBag()
    
    init(_ navigationController: LunchatNavigationController) {
        self.navigationController = navigationController
        NotificationCenter.default.addObserver(self, selector: #selector(leaveRoomSuccess), name: NSNotification.Name.leaveRoomSuccess, object: nil)
    }
    
    func start() {
        let searchViewController = getSearchViewController()
        navigationController.pushViewController(searchViewController, animated: false)
    }
    
    @objc
    private func leaveRoomSuccess() {
        NotificationCenter.default.post(name: NSNotification.Name.removeSideMenu, object: nil)
        navigationController.popViewController(animated: true)
    }
}

// MARK: - SearchAppointment & AppointmentDetail

extension SearchCoordinator: SearchAppointmentViewDelegate {
    
    func showAppointmentDetailView(id: String) {
        let detailViewController = getAppointmentDetailViewController(appointmentId: id)
        navigationController.visibleViewController?.setNavBackButton(title: "밥약")
        navigationController.pushViewController(detailViewController, animated: true)
    }
}

extension SearchCoordinator: AppointmentDetailViewDelegate {
    
    func showAppointmentJoinBottomSheet(checkAction: @escaping () -> Void) {
        let viewController = AppointmentJoin()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getCheckButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            checkAction()
            viewController?.dismiss(animated: true)
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
    
    func showAppointmentJoinSuccess() {
        let viewController = AppointmentJoinSuccess()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
            self?.navigationController.popViewController(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak self, weak viewController] in
            viewController?.dismiss(animated: true)
            self?.navigationController.popViewController(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showAppointmentJoinFailure() {
        let viewController = AppointmentJoinFailure()
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

// MARK: - Profile

extension SearchCoordinator: ProfileBottomSheetDelegate {
    
    // bottomSheet
    func showUserProfileView(nickname: String) {
        let viewController = getProfileBottomSheet(nickname: nickname)
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getViewTapGesture().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        navigationController.visibleViewController?.setNavBackButton(title: "")
        navigationController.present(viewController, animated: false)
    }
    
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
    
    func showPersonalChatViewController(chatRoom: ChatRoom, _ initMessage: String? = nil) {
        let chatViewController = getChatViewController(chatRoom: chatRoom, initMessage)
        let nickname = UserDefaults.standard.getUserInfo(.nickname)
        let partner = chatRoom.participants.filter{ $0.nickname != nickname }
        chatViewController.title = partner.first?.nickname
        
        navigationController.visibleViewController?.setNavBackButton(title: "")
        navigationController.pushViewController(chatViewController, animated: true)
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

extension SearchCoordinator: ShopViewDelegate {
    
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

//MARK: - Chat

extension SearchCoordinator: ChatViewDelegate {
    
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

extension SearchCoordinator {
    
    private func getSearchViewController() -> SearchViewController {
        let searchRepository = SearchRepository()
        let searchUseCase = SearchUseCase(searchRespository: searchRepository)
        let searchAppointmentViewModel = SearchAppointmentViewModel(useCase: searchUseCase, delegate: self)
        let searchAppointmentViewController = SearchAppointmentViewController(viewModel: searchAppointmentViewModel)
        
        let searchUserViewModel = SearchUserViewModel(useCase: searchUseCase, delegate: self)
        let searchUserViewController = SearchUserViewController(viewModel: searchUserViewModel)
        
        return SearchViewController(viewControllers: [searchAppointmentViewController, searchUserViewController])
    }
    
    private func getProfileBottomSheet(nickname: String) -> ProfileBottomSheet {
        let repository = ProfileBottomSheetRepository()
        let useCase = ProfileBottomSheetUseCase(profileBottomSheetRepository: repository)
        let viewModel = ProfileBottomSheetViewModel(nickname: nickname, useCase: useCase, delegate: self)
        return ProfileBottomSheet(viewModel: viewModel)
    }
    
    private func getAppointmentDetailViewController(appointmentId: String) -> AppointmentDetailViewController {
        let appointmentRepository = AppointmentRepository()
        let appointmentUseCase = AppointmentUseCase(appointmentRespository: appointmentRepository)
        let appointmentDetailViewModel = AppointmentDetailViewModel(appointmentId: appointmentId, appointmentUseCase: appointmentUseCase, delegate: self)
        let detailViewController = AppointmentDetailViewController(viewModel: appointmentDetailViewModel)
        return detailViewController
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
    
    private func getChatViewController(chatRoom: ChatRoom, _ initMessage: String? = nil) -> ChatViewController {
        let chatRepository = ChatRepository()
        let chatUseCase = ChatUseCase(chatRepository: chatRepository)
        let fileRepository = FileRepository()
        let fileUseCase = FileUseCase(fileRepository: fileRepository)
        let viewModel = ChatViewModel(chatRoom: chatRoom, chatUseCase: chatUseCase, fileUseCase: fileUseCase, delegate: self, initMessage)
        let viewController = ChatViewController(viewModel: viewModel)
        
        return viewController
    }
}
