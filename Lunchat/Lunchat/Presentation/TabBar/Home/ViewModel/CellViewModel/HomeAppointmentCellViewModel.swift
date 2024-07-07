//
//  HomeAppointmentCellViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/01.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeAppointmentCellViewModel: BaseViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    let isLeft = PublishSubject<Bool>()
    let isJoined = PublishSubject<Bool>()
    
    private let useCase: AppointmentUseCase
    private weak var homeViewDelegate: HomeCellDelegate?
    var disposeBag = DisposeBag()
    
    init(useCase: AppointmentUseCase, delegate: HomeCellDelegate?) {
        self.useCase = useCase
        self.homeViewDelegate = delegate
    }
    
    func transform(input: Input) -> Output {
        return Output()
    }
    
    func showJoinAppointment(id: String) {
        homeViewDelegate?.showAppointmentJoinView(id: id, viewModel: self)
    }
    
    func joinAppointment(id: String) {
        useCase.joinAppointment(appointmentId: id)
        
        useCase.isJoined.subscribe({ [weak self] isSuccess in
            if let isSuccess = isSuccess.element, isSuccess {
                self?.isJoined.onNext(true)
            } else {
                self?.isJoined.onNext(false)
            }
        })
        .disposed(by: disposeBag)
    }
    
    func showLeavAppointment() {
        if UserStatusTracker.shared.getUserStatus() == .made {
            homeViewDelegate?.showAppointmentCancelView(viewModel: self)
        } else {
            homeViewDelegate?.showAppointmentLeaveView(viewModel: self)
        }
    }
    
    func leaveAppointment() {
        
        useCase.deleteAppointment()
        
        useCase.isLeft.subscribe({ [weak self] isLeft in
            if let isLeft = isLeft.element, isLeft {
                self?.isLeft.onNext(true)
            } else {
                self?.isLeft.onNext(false)
            }
        })
        .disposed(by: disposeBag)
    }
}
