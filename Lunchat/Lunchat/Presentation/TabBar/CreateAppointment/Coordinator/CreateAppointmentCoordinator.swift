//
//  CreateAppointmentCoordinator.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/30.
//

import UIKit
import RxSwift

final class CreateAppointmentCoordinator: Coordinator {
    
    var delegate: CoordinatorDelegate?
    var navigationController: LunchatNavigationController
    var childCoordinators = [Coordinator]()
    var type: CoordinatorType = .home
    private var createAppointment = RequestCreateAppointment.empty
    private var disposeBag = DisposeBag()
    
    init(_ navigationController: LunchatNavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = getAppointmentMenuViewController()
        navigationController.visibleViewController?.setNavBackButton(title: "밥약 생성 (1/5)")
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func finish() {
        delegate?.didFinish(childCoordinator: self)
    }
    
    func showAppointmentCreateSuccess() {
        let viewController = AppointmentCreateSuccess()
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.getButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
            let notification = Foundation.Notification(name: Foundation.Notification.Name.reloadAppointments, object: nil)
            NotificationCenter.default.post(notification)
            self?.navigationController.popToRootViewController(animated: true)
            self?.finish()
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak self, weak viewController] in
            viewController?.dismiss(animated: true)
            let notification = Foundation.Notification(name: Foundation.Notification.Name.reloadAppointments, object: nil)
            NotificationCenter.default.post(notification)
            self?.navigationController.popToRootViewController(animated: true)
            self?.finish()
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    func showAppointmentCreateFailure() {
        let viewController = AppointmentCreateFailure()
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
    
    deinit {
        disposeBag = DisposeBag()
    }
}

extension CreateAppointmentCoordinator: CreateAppointmentDelegate {
    // viewControllers
    func showTimeViewController(menuType: MenuType) {
        createAppointment.menu = menuType.rawValue.uppercased()

        let viewController = getAppointmentTimeViewController()
        navigationController.visibleViewController?.setNavBackButton(title: "밥약 생성 (2/5)")
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showParticipiantViewController(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZ"

        createAppointment.scheduledAt = dateFormatter.string(from: date)
        
        let viewController = getAppointmentParticipantViewController()
        navigationController.visibleViewController?.setNavBackButton(title: "밥약 생성 (3/5)")
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showLocationViewController(count: Int) {
        createAppointment.maxParticipants = count
        
        let viewController = getAppointmentLocationViewController()
        navigationController.visibleViewController?.setNavBackButton(title: "밥약 생성 (4/5)")
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showMapViewController(lat: Double, long: Double) {
        let viewController = getAppointmentMapViewController(lat: lat, long: long)
        navigationController.visibleViewController?.setNavBackButton(title: "밥약 생성 (4/5)")
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showInfoViewController(locationInfo: SearchedPlace) {
        createAppointment.placeTitle = locationInfo.title
        createAppointment.placeAddress = locationInfo.address
        createAppointment.placeRoadAddress = locationInfo.roadAddress
        
        let viewController = getInfoViewController()
        navigationController.visibleViewController?.setNavBackButton(title: "밥약 생성 (5/5)")
        navigationController.pushViewController(viewController, animated: true)
    }
    
    // bottomSheets
    func showInAccessableLocation() {
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
    
    func showAppointmentCreate(request: RequestCreateAppointment, viewModel: CreateAppointmentViewModel) {
        let viewController = AppointmentCreate(viewModel: viewModel)
        viewController.modalPresentationStyle = .overFullScreen

        viewController.getCancelButtonObservable().subscribe(onNext: { [weak self, weak viewController] _ in
            viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
        
        viewController.getCheckButtonObservable().subscribe(onNext: { [weak viewController] _ in
            viewController?.createAppointment(request: request)
        })
        .disposed(by: disposeBag)
        
        viewController.getIsCreatedObservable().subscribe(onNext: { [weak self, weak viewController] isCreated in
            viewController?.dismiss(animated: true) {
                if isCreated {
                    UserStatusTracker.shared.setUserStatus(status: .made)
                    self?.showAppointmentCreateSuccess()
                } else {
                    self?.showAppointmentCreateFailure()
                }
            }
        })
        .disposed(by: disposeBag)
        
        viewController.setHidable { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        navigationController.present(viewController, animated: false)
    }
    
    // coordinator delegate
    func finishCoordinator() {
        finish()
    }
    
    // etc
    func getAppointment() -> RequestCreateAppointment {
        return createAppointment
    }
}

extension CreateAppointmentCoordinator {

    func getAppointmentMenuViewController() -> AppointmentMenuViewController {
        let repository = CreateAppointmentRepository()
        let useCase = CreateAppointmentUseCase(createAppointmentRepository: repository)
        let viewModel = CreateAppointmentViewModel(useCase: useCase, delegate: self)
        return AppointmentMenuViewController(viewModel: viewModel)
    }
    
    func getAppointmentTimeViewController() -> AppointmentTimeViewController {
        let repository = CreateAppointmentRepository()
        let useCase = CreateAppointmentUseCase(createAppointmentRepository: repository)
        let viewModel = CreateAppointmentViewModel(useCase: useCase, delegate: self)
        return AppointmentTimeViewController(viewModel: viewModel)
    }
    
    func getAppointmentParticipantViewController() -> AppointmentParticipantViewController {
        let repository = CreateAppointmentRepository()
        let useCase = CreateAppointmentUseCase(createAppointmentRepository: repository)
        let viewModel = CreateAppointmentViewModel(useCase: useCase, delegate: self)
        return AppointmentParticipantViewController(viewModel: viewModel)
    }
    
    func getAppointmentLocationViewController() -> AppointmentLocationViewController {
        let repository = CreateAppointmentRepository()
        let useCase = CreateAppointmentUseCase(createAppointmentRepository: repository)
        let viewModel = CreateAppointmentViewModel(useCase: useCase, delegate: self)
        return AppointmentLocationViewController(viewModel: viewModel)
    }
    
    func getAppointmentMapViewController(lat: Double, long: Double) -> AppointmentMapViewController {
        let repository = CreateAppointmentRepository()
        let useCase = CreateAppointmentUseCase(createAppointmentRepository: repository)
        let viewModel = CreateAppointmentViewModel(useCase: useCase, delegate: self)
        return AppointmentMapViewController(viewModel: viewModel, lat: lat, long: long)
    }
    
    func getInfoViewController() -> AppointmentInfoViewController {
        let repository = CreateAppointmentRepository()
        let useCase = CreateAppointmentUseCase(createAppointmentRepository: repository)
        let viewModel = CreateAppointmentViewModel(useCase: useCase, delegate: self)
        return AppointmentInfoViewController(viewModel: viewModel)
    }
}
