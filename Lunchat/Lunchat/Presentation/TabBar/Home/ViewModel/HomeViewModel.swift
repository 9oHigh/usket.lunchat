//
//  AppointmentViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/09.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

final class HomeViewModel: BaseViewModel {
    
    struct Input {
        let toNotificationSignal: Signal<Void>
    }
    
    struct Output {
        let userInfo: PublishSubject<UserInformation>
        let appointments: BehaviorSubject<[Appointment]>
    }
    
    private let userUseCase: UserUseCase
    private let appointmentUseCase: AppointmentUseCase
    private weak var homeViewDelegate: HomeViewDelegate?
    var disposeBag = DisposeBag()
    
    private let userInfo = PublishSubject<UserInformation>()
    private let profileImageUrl = PublishSubject<URL?>()
    private let appointments = BehaviorSubject<[Appointment]>(value: [])
    
    private var page = 0
    private var hasNextPage: Bool = true
    private let take = 10
    private var total = 0
    private var needRefresh = false
    
    init(userUseCase: UserUseCase, appointmentUseCase: AppointmentUseCase, delegate: HomeViewDelegate?) {
        self.userUseCase = userUseCase
        self.appointmentUseCase = appointmentUseCase
        self.homeViewDelegate = delegate
    }
    
    func transform(input: Input) -> Output {
        
        input.toNotificationSignal.emit { [weak self] _ in
            self?.homeViewDelegate?.showNotificationViewController()
        }
        .disposed(by: disposeBag)
        
        appointmentUseCase.appointments
            .subscribe(onNext: { [weak self] appointments in
                guard let self = self,
                      let appointments = appointments,
                      UserStatusTracker.shared.getUserStatus() == .nothing
                else { return }
                
                self.total = appointments.meta.total
                self.hasNextPage = appointments.meta.hasNextPage
                
                var updatedAppointments: [Appointment] = []
                
                if appointments.data.isEmpty {
                    if self.total != 0, let existing = try? self.appointments.value() {
                        updatedAppointments = existing
                    } else {
                        updatedAppointments = []
                    }
                } else {
                    if let existing = try? self.appointments.value() {
                        if self.needRefresh {
                            updatedAppointments = self.updateAppointments(existingAppointments: existing, newData: appointments.data)
                            self.needRefresh = false
                        } else {
                            updatedAppointments = existing + appointments.data
                        }
                    } else {
                        updatedAppointments = appointments.data
                    }
                }
                
                self.appointments.onNext(updatedAppointments)
            })
            .disposed(by: disposeBag)
        
        userUseCase.userInfo
            .subscribe(onNext: { [weak self] userInfo in
                guard let userInfo = userInfo else { return }
                self?.userInfo.onNext(userInfo)
            })
            .disposed(by: disposeBag)
        
        appointmentUseCase.schedule
            .subscribe(onNext: { [weak self] schedule in
                if let userSchedule = schedule {
                    if userSchedule.isOrganizer {
                        UserStatusTracker.shared.setUserStatus(status: .made)
                    } else {
                        UserStatusTracker.shared.setUserStatus(status: .participated)
                    }
                    self?.appointments.onNext([userSchedule])
                } else {
                    UserStatusTracker.shared.setUserStatus(status: .nothing)
                    self?.getAppointments()
                }
            })
            .disposed(by: disposeBag)
        
        return Output(userInfo: userInfo, appointments: appointments)
    }
    
    func setUserCoords(coords: Coordinate) {
        userUseCase.setUserCoords(coords: coords)
    }
    
    func setUserNotification(isAllowed: Bool) {
        userUseCase.setUserNotification(allowPushNotification: isAllowed)
    }
    
    func getUserInfo() {
        userUseCase.getUserInfo()
    }
    
    func getAppointments() {
        appointmentUseCase.getAllAppointments(page: self.page, take: self.take)
    }
    
    func getUserSchedule() {
        appointmentUseCase.getScheduleOfUser()
    }
    
    func setNeedRefresh(_ isNeed: Bool) {
        needRefresh = isNeed
    }
    
    func getAppointmentCount() -> Int? {
        return try? appointments.value().count
    }
    
    func isLastAppointment() -> Bool {
        if let existing = try? appointments.value() {
            return existing.count == total
        }
        return false
    }
    
    func resetAppointments() {
        page = 0
        total = 0
        appointmentUseCase.getAllAppointments(page: page, take: take)
    }
    
    func loadMoreAppointment() {
        
        if let appointments = try? self.appointments.value(), appointments.count > total ||
            !hasNextPage {
            return
        }
        
        page += 1
        appointmentUseCase.getAllAppointments(page: self.page, take: self.take)
    }
    
    private func updateAppointments(existingAppointments: [Appointment], newData: [Appointment]) -> [Appointment] {
        let existingAppointmentIds = Set(existingAppointments.map { $0.id })
        let newDataAppointmentIds = Set(newData.map { $0.id })
        let commonAppointmentIds = existingAppointmentIds.intersection(newDataAppointmentIds)
        var updatedExistingAppointments = existingAppointments.filter { commonAppointmentIds.contains($0.id) }
        
        for newDataAppointment in newData {
            if let index = updatedExistingAppointments.firstIndex(where: { $0.id == newDataAppointment.id }) {
                updatedExistingAppointments[index] = newDataAppointment
            } else {
                updatedExistingAppointments.append(newDataAppointment)
            }
        }
        
        return updatedExistingAppointments
    }
    
    func showLocationPermission() {
        homeViewDelegate?.showLocationPermission()
    }
}

// MARK: - Home Cell

extension HomeViewModel: HomeCellDelegate {
    
    func moveToCreateAppointmentCoordinator() {
        homeViewDelegate?.moveToCreateAppointmentCoordinator()
    }
    
    func showAppointmentJoinView(id: String, viewModel: HomeAppointmentCellViewModel) {
        homeViewDelegate?.showAppointmentJoinView(id: id, viewModel: viewModel)
    }
    
    func showAppointmentCancelView(viewModel: HomeAppointmentCellViewModel) {
        homeViewDelegate?.showAppointmentCancelView(viewModel: viewModel)
    }
    
    func showAppointmentLeaveView(viewModel: HomeAppointmentCellViewModel) {
        homeViewDelegate?.showAppointmentLeaveView(viewModel: viewModel)
    }
}

extension HomeViewModel {
    
    func getHomeAppointmentCellViewModel() -> HomeAppointmentCellViewModel {
        return HomeAppointmentCellViewModel(useCase: appointmentUseCase, delegate: self)
    }
    
    func getHomeCreateAppointmentCellViewModel() -> HomeCreateAppointmentCellViewModel {
        return HomeCreateAppointmentCellViewModel(useCase: appointmentUseCase, delegate: self)
    }
}
