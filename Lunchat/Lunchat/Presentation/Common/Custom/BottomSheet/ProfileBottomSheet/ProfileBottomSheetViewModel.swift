//
//  ProfileBottomSheetViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/06/17.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileBottomSheetViewModel: BaseViewModel {
    
    struct Input {
        let useTicketSignal: Signal<Void>?
        let reportUserSignal: Signal<Void>?
    }
    
    struct Output {
        let profile: PublishSubject<Profile?>
    }
    
    private let nickname: String
    private var ticketCount: Int?
    private let profile = PublishSubject<Profile?>()
    
    private let useCase: ProfileBottomSheetUseCase
    private weak var profileBottomSheetDelegate: ProfileBottomSheetDelegate?
    
    var disposeBag = DisposeBag()
    
    init(nickname: String, useCase: ProfileBottomSheetUseCase, delegate: ProfileBottomSheetDelegate) {
        self.nickname = nickname
        self.useCase = useCase
        self.profileBottomSheetDelegate = delegate
    }
    
    func transform(input: Input) -> Output {
        
        input.useTicketSignal?.skip(1).emit(onNext: { [weak self] _ in
            self?.useCase.getCountUnUsed()
        })
        .disposed(by: disposeBag)
        
        useCase.unUsedCount.subscribe(onNext: { [weak self] unused in
            guard let self = self, let unused = unused else {
                return
            }
            self.ticketCount = unused.ticketCount
            if unused.ticketCount > 0 {
                self.profileBottomSheetDelegate?.showUseTicketView(nickname: nickname, viewModel: self)
            } else {
                self.profileBottomSheetDelegate?.showEmptyTicket()
            }
        })
        .disposed(by: disposeBag)
        
        input.reportUserSignal?.skip(1).emit(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.profileBottomSheetDelegate?.showReportUserView(nickname: nickname, viewModel: self)
        })
        .disposed(by: disposeBag)
        
        useCase.isReportedUser.subscribe(onNext: { [weak self] isSuccess in
            if isSuccess {
                self?.profileBottomSheetDelegate?.showReportSuccess()
            } else {
                self?.profileBottomSheetDelegate?.showReportFailure()
            }
        })
        .disposed(by: disposeBag)
        
        useCase.userProfile.subscribe(onNext: { [weak self] profile in
            guard let profile = profile
            else {
                self?.profile.onNext(nil)
                return
            }
            self?.profile.onNext(profile)
        })
        .disposed(by: disposeBag)
        
        useCase.getUserProfile(nickname: nickname)
        
        return Output(profile: profile)
    }
    
    func reportUser(nickname: String, reason: String) {
        useCase.reportUser(nickname: nickname, reason: reason)
    }
    
    func getTicketCount() -> Int? {
        return ticketCount
    }
    
    func useTicket(toNickname: String, initMessage: String?, completion: @escaping (Bool) -> Void) {
        useCase.roomId.subscribe(onNext: { [weak self] id in
            if let roomId = id {
                self?.getPersonalChatRoom(id: roomId, initMessage: initMessage, completion: completion)
            } else {
                completion(false)
                self?.profileBottomSheetDelegate?.showUseTicketFailure()
            }
        })
        .disposed(by: disposeBag)
        
        useCase.useTicket(toNickname: nickname)
    }
    
    func getPersonalChatRoom(id: String, initMessage: String?, completion: @escaping (Bool) -> Void) {
        
        useCase.chatRoom.subscribe(onNext: { [weak self] chatRoom in
            if let room = chatRoom {
                completion(true)
                self?.profileBottomSheetDelegate?.showPersonalChatViewController(chatRoom: room, initMessage)
            }
        })
        .disposed(by: disposeBag)
        
        useCase.getSpecificChatRoom(id: id)
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
}
