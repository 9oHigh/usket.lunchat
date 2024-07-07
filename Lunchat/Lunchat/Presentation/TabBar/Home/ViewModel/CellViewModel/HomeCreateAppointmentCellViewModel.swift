//
//  HomeCreateAppointmentCellViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/07/01.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeCreateAppointmentCellViewModel: BaseViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
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
    
    func createAppointment() {
        homeViewDelegate?.moveToCreateAppointmentCoordinator()
    }
}
