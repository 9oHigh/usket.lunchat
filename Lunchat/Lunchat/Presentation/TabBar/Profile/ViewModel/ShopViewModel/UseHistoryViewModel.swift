//
//  UseHistoryViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/03/06.
//

import Foundation
import RxSwift
import RxCocoa

final class UseHistoryViewModel: BaseViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        let histories: BehaviorSubject<[UseHistory]>
    }
    
    let isLoading = BehaviorSubject<Bool>(value: false)
    private var hasNextPage: Bool = true
    private var page = 0
    private let take = 10
    private var total = 0
    
    private let histories = BehaviorSubject<[UseHistory]>(value: [])
    
    private let useCase: TicketUseCase
    var disposeBag = DisposeBag()
    
    init(useCase: TicketUseCase) {
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        
        useCase.useHistories
            .subscribe({ [weak self] histories in
                if let histories = histories.element,
                   let histories = histories {
                    self?.total = histories.meta.total
                    self?.hasNextPage = histories.meta.hasNextPage
                    
                    if histories.data.isEmpty {
                        if self?.total != 0 {
                            if let existing = try? self?.histories.value() {
                                self?.histories.onNext(existing)
                            }
                        } else {
                            self?.histories.onNext([])
                        }
                    } else {
                        if let existing = try? self?.histories.value() {
                            self?.histories.onNext(existing + histories.data)
                        } else {
                            self?.histories.onNext(histories.data)
                        }
                    }
                } else {
                    self?.histories.onNext([])
                }
            })
            .disposed(by: disposeBag)
        
        return Output(histories: histories)
    }
    
    func getUseHistories() {
        isLoading.onNext(true)
        useCase.getUseHistories(page: page, take: take) { [weak self] in
            self?.isLoading.onNext(false)
        }
    }
    
    func getMoreUseHistories() {
        
        if let isLoading = try? isLoading.value(), isLoading {
            return
        }
        
        if let histories = try? histories.value(), histories.count > total {
            isLoading.onNext(false)
            return
        }
        
        if !hasNextPage { return }
        
        page += 1
        
        isLoading.onNext(true)
        
        useCase.getUseHistories(page: self.page, take: self.take) { [weak self] in
            self?.isLoading.onNext(false)
        }
    }
}
