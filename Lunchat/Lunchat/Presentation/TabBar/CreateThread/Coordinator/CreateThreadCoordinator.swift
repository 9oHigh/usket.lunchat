//
//  CreateThreadCoordinator.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/24.
//

import RxSwift
import Foundation

final class CreateThreadCoordinator: Coordinator {

    var delegate: CoordinatorDelegate?
    var navigationController: LunchatNavigationController
    var childCoordinators = [Coordinator]()
    var type: CoordinatorType = .thread
    
    private var createThread = RequestCreateThread.empty
    private var disposeBag = DisposeBag()
    
    init(_ navigationController: LunchatNavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = getCreateThreadLocationViewController()
        navigationController.visibleViewController?.setNavBackButton(title: "맛집 공유 (1/2)")
        navigationController.pushViewController(viewController, animated: true)
    }
}

// MARK: - CreateThread

extension CreateThreadCoordinator: CreateThreadViewDelegate {
    
    func showMapViewController(lat: Double, long: Double) {
        let viewController = getCreateThreadMapViewController(lat: lat, long: long)
        navigationController.visibleViewController?.setNavBackButton(title: "맛집 공유 (1/2)")
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showInAccessableLocationView() {
        let viewController = MapInAccessable()
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
    
    func showMapChosenFailure() {
        let viewController = MapChosenFailure()
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
    
    func showInfoViewController(locationInfo: SearchedPlace) {
        createThread.placeTitle = locationInfo.title
        createThread.placeAddress = locationInfo.address
        createThread.placeRoadAddress = locationInfo.roadAddress
        
        let viewController = getCreateThreadInfoViewController(title: locationInfo.title)
        navigationController.visibleViewController?.setNavBackButton(title: "맛집 공유 (2/2)")
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showPhotoUploadFailure() {
        let viewController = ThreadPhotoUploadFailure()
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

    func showCreateThreadSuccess() {
        let viewController = NewThreadSuccess()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true) {
                guard let self = self else { return }
                NotificationCenter.default.post(name: NSNotification.Name.reloadPosts, object: nil)
                self.navigationController.popToRootViewController(animated: true)
                self.delegate?.didFinish(childCoordinator: self)
            }
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak self, weak viewController] in
            viewController?.dismiss(animated: true) {
                guard let self = self else { return }
                NotificationCenter.default.post(name: NSNotification.Name.reloadPosts, object: nil)
                self.navigationController.popToRootViewController(animated: true)
                self.delegate?.didFinish(childCoordinator: self)
            }
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showCreateThreadFailure() {
        let viewController = NewThreadFailure()
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
    
    func finishCreateThread() {
        disposeBag = DisposeBag()
        delegate?.didFinish(childCoordinator: self)
    }
    
    func getCreateThreadParm() -> RequestCreateThread {
        return createThread
    }
}

extension CreateThreadCoordinator {
    
    private func getCreateThreadLocationViewController() -> CreateThreadLocationViewController {
        let threadRepository = CreateThreadRepository()
        let threadUseCase = CreateThreadUseCase(createThreadRepository: threadRepository)
        
        let fileRepository = FileRepository()
        let fileUseCase = FileUseCase(fileRepository: fileRepository)
        
        let viewModel = CreateThreadViewModel(useCase: threadUseCase, fileUseCase: fileUseCase, delegate: self)
        let viewController = CreateThreadLocationViewController(viewModel: viewModel)
        
        return viewController
    }
    
    private func getCreateThreadMapViewController(lat: Double, long: Double) -> CreateThreadMapViewController {
        let threadRepository = CreateThreadRepository()
        let threadUseCase = CreateThreadUseCase(createThreadRepository: threadRepository)
        
        let fileRepository = FileRepository()
        let fileUseCase = FileUseCase(fileRepository: fileRepository)
        
        let viewModel = CreateThreadViewModel(useCase: threadUseCase, fileUseCase: fileUseCase, delegate: self)
        let viewController = CreateThreadMapViewController(viewModel: viewModel, lat: lat, long: long)
        
        return viewController
    }
    
    private func getCreateThreadInfoViewController(title: String) -> CreateThreadInfoViewController {
        let threadRepository = CreateThreadRepository()
        let threadUseCase = CreateThreadUseCase(createThreadRepository: threadRepository)
        
        let fileRepository = FileRepository()
        let fileUseCase = FileUseCase(fileRepository: fileRepository)
        
        let viewModel = CreateThreadViewModel(useCase: threadUseCase, fileUseCase: fileUseCase, delegate: self)
        viewModel.setRestaurantTitle(title: title)
        
        let viewController = CreateThreadInfoViewController(viewModel: viewModel)
        
        return viewController
    }
}
