//
//  AppointmentDetailViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/05.
//

import Foundation
import RxSwift
import RxCocoa

final class AppointmentDetailViewModel: BaseViewModel {
    
    struct Input {
        let participantSign: Signal<Void>
    }
    
    struct Output {
        let members: PublishSubject<[Participant?]>
        let hashtags: PublishSubject<[String]>
        let appointment: PublishSubject<Appointment>
        let isActive: PublishSubject<Bool>
    }
    
    private var appointmentId: String
    private let members = PublishSubject<[Participant?]>()
    private let hashtags = PublishSubject<[String]>()
    private let appointment = PublishSubject<Appointment>()
    private let isActive = PublishSubject<Bool>()
    
    private let appointmentUseCase: AppointmentUseCase
    private weak var appointmentDetailViewDelegate: AppointmentDetailViewDelegate?
    var disposeBag = DisposeBag()
    
    init(appointmentId: String, appointmentUseCase: AppointmentUseCase, delegate: AppointmentDetailViewDelegate) {
        self.appointmentId = appointmentId
        self.appointmentUseCase = appointmentUseCase
        self.appointmentDetailViewDelegate = delegate
    }
    
    func transform(input: Input) -> Output {
        
        input.participantSign.emit { [weak self] _ in
            self?.appointmentDetailViewDelegate?.showAppointmentJoinBottomSheet { [weak self] in
                guard let appointmentId = self?.appointmentId else {
                    self?.appointmentDetailViewDelegate?.showAppointmentJoinFailure()
                    return
                }
                self?.appointmentUseCase.joinAppointment(appointmentId: appointmentId)
            }
        }
        .disposed(by: disposeBag)
        
        appointmentUseCase.isJoined.subscribe(onNext: { [weak self] isJoined in
            if isJoined {
                UserStatusTracker.shared.setUserStatus(status: .participated)
                self?.appointmentDetailViewDelegate?.showAppointmentJoinSuccess()
            } else {
                self?.appointmentDetailViewDelegate?.showAppointmentJoinFailure()
            }
        })
        .disposed(by: disposeBag)
        
        appointmentUseCase.appointment.subscribe(onNext: { [weak self] appointment in
            if let appointment = appointment {
                self?.appointment.onNext(appointment)
                
                var participants: [Participant?] = appointment.participants
                
                if participants.count == appointment.maxParticipants || UserStatusTracker.shared.getUserStatus() == .made || UserStatusTracker.shared.getUserStatus() == .participated {
                    self?.isActive.onNext(false)
                } else {
                    self?.isActive.onNext(true)
                }
                
                while participants.count < appointment.maxParticipants {
                    participants.append(nil)
                }
                
                self?.members.onNext(participants)
                
                if let hashTags = appointment.hashTags {
                    self?.hashtags.onNext(hashTags)
                }
            }
        })
        .disposed(by: disposeBag)
        
        fetchAppointment(id: appointmentId)

        return Output(members: members, hashtags: hashtags, appointment: appointment, isActive: isActive)
    }
    
    func fetchAppointment(id: String) {
        appointmentUseCase.getAppointment(id: id)
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
}
