//
//  SearchViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/14.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchAppointmentViewModel: BaseViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        let appointments: BehaviorSubject<[Appointment]>
    }
    
    let isLoading = BehaviorSubject<Bool>(value: false)
    private var hasNextPage: Bool = true
    private var page = 0
    private let take = 10
    private var total = 0
    private var keyword: String = ""
    private let appointments = BehaviorSubject<[Appointment]>(value: [])
    
    private let useCase: SearchUseCase
    private weak var searchAppointmentViewDelegate: SearchAppointmentViewDelegate?
    var disposeBag = DisposeBag()
    
    init(useCase: SearchUseCase, delegate: SearchAppointmentViewDelegate) {
        self.useCase = useCase
        self.searchAppointmentViewDelegate = delegate
    }
    
    func transform(input: Input) -> Output {
        
        self.useCase.appointments.subscribe({ [weak self] appointments in
            if let appointments = appointments.element, let appointments = appointments {
                
                self?.total = appointments.meta.total
                self?.hasNextPage = appointments.meta.hasNextPage
                
                if appointments.data.isEmpty {
                    if self?.total != 0, let existing = try? self?.appointments.value() {
                        self?.appointments.onNext(existing)
                    } else {
                        self?.appointments.onNext([])
                    }
                } else {
                    if let existing = try? self?.appointments.value() {
                        self?.appointments.onNext(existing + appointments.data)
                    } else {
                        self?.appointments.onNext(appointments.data)
                    }
                }
            } else {
                self?.appointments.onNext([])
            }
        })
        .disposed(by: disposeBag)
        
        return Output(appointments: appointments)
    }
    
    func getAppointment(keyword: String = "", option: String = "") {
        self.keyword = keyword
        
        isLoading.onNext(true)
        
        useCase.searchAppointment(page: page, take: take, keyword: keyword, option: option) { [weak self] in
            self?.isLoading.onNext(false)
        }
    }
    
    func getMoreAppointments() {
        
        if let isLoading = try? isLoading.value(), isLoading {
            return
        }
        
        if let appointments = try? appointments.value(), appointments.count > total {
            isLoading.onNext(false)
            return
        }
        
        if !hasNextPage { return }
        
        page += 1
        
        isLoading.onNext(true)
        
        useCase.searchAppointment(page: page, take: take, keyword: keyword) { [weak self] in
            self?.isLoading.onNext(false)
        }
    }
    
    func setDefaultPageOptions() {
        page = 0
        total = 0
        keyword = ""
        appointments.onNext([.empty])
    }
    
    func setKeyword(text: String) {
        keyword = text
    }
    
    func showAppointmentDetailView(id: String) {
        searchAppointmentViewDelegate?.showAppointmentDetailView(id: id)
    }
}
