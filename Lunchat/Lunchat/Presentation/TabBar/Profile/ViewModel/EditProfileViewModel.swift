//
//  EditProfileViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/05/25.
//

import UIKit
import RxSwift
import RxCocoa

final class EditProfileViewModel: BaseViewModel {
    
    struct Input {
        let editPhotoSign: Signal<Void>?
        let gender: Signal<Bool>?
        let introduceText: Signal<String>?
        let saveSign: Signal<UpdateUserInformation?>?
    }
    
    struct Output {
        let isAvailableNickname: PublishSubject<Bool>
        let showImagePickerSign: PublishSubject<Bool>
        let profile: PublishSubject<Profile?>
    }
    
    private let optionsRelay = BehaviorRelay<[String: Any]>(value: [:])
    private let isAvailableNickname = PublishSubject<Bool>()
    private let showImagePickerSign = PublishSubject<Bool>()
    private let profile = PublishSubject<Profile?>()
    private var profileImageUrl: String?
    
    private let fileUseCase: FileUseCase
    private let userUseCase: UserUseCase
    private weak var editProfileViewDelegate: EditProfileViewDelegate?
    var disposeBag = DisposeBag()
    
    init(fileUseCase: FileUseCase, userUseCase: UserUseCase, delegate: EditProfileViewDelegate?) {
        self.fileUseCase = fileUseCase
        self.userUseCase = userUseCase
        self.editProfileViewDelegate = delegate
    }
    
    func transform(input: Input) -> Output {
        
        input.editPhotoSign?.emit { [weak self] _ in
            self?.showImagePickerSign.onNext(true)
        }
        .disposed(by: disposeBag)
        
        input.gender?.emit { [weak self] isMan in
            self?.updateOption("gender", with: isMan)
        }
        .disposed(by: disposeBag)
        
        input.introduceText?.emit { [weak self] text in
            if text.isEmpty {
                self?.updateOption("bio", with: false)
            } else {
                self?.updateOption("bio", with: true)
            }
        }
        .disposed(by: disposeBag)
        
        input.saveSign?.emit { [weak self] userInfo in
            guard let self = self,
                  let userInfo = userInfo
            else { return }
            
            let profilePictrue = self.profileImageUrl
            let nickname = userInfo.nickname
            let gender = userInfo.gender
            let bio = userInfo.bio
            var modifiedParm: [String: Any] = [:]
            
            if let profilePictrue = profilePictrue, !profilePictrue.isEmpty, profilePictrue != UserDefaults.standard.getUserInfo(.profilePicture)! {
                modifiedParm["profilePicture"] = profilePictrue
            }
            
            if let nickname = nickname, !nickname.isEmpty, nickname != UserDefaults.standard.getUserInfo(.nickname)! {
                modifiedParm["nickname"] = nickname
            }
            
            if let gender = gender, gender != UserDefaults.standard.getUserGender() {
                modifiedParm["gender"] = gender
            }
            
            if let bio = bio, !bio.isEmpty, bio != UserDefaults.standard.getUserInfo(.bio)! {
                modifiedParm["bio"] = bio
            }
            
            if !modifiedParm.isEmpty {
                self.editProfileViewDelegate?.showProfileStoreView(viewModel: self, userInfo: modifiedParm)
            }
        }
        .disposed(by: disposeBag)
        
        userUseCase.isAvailableNickname.subscribe({ [weak self] available in
            if let available = available.element, available {
                self?.updateOption("nickname", with: true)
                self?.isAvailableNickname.onNext(true)
            } else {
                self?.updateOption("nickname", with: false)
                self?.isAvailableNickname.onNext(false)
            }
        })
        .disposed(by: disposeBag)
        
        userUseCase.isUpdatedUserInfo.subscribe({ [weak self] isUpdated in
            if let isUpdated = isUpdated.element, isUpdated {
                self?.editProfileViewDelegate?.showProfileStoreSuccess()
            } else {
                self?.editProfileViewDelegate?.showProfileStoreFailure()
            }
        })
        .disposed(by: disposeBag)
        
        userUseCase.userProfile.subscribe({ [weak self] profileInfo in
            guard let profileInfo = profileInfo.element,
                  let profile = profileInfo
            else {
                self?.profile.onNext(nil)
                return
            }
            self?.profile.onNext(profile)
        })
        .disposed(by: disposeBag)
        
        fileUseCase.presignedUrl.subscribe({ [weak self] url in
            if let url = url.element, url == nil {
                self?.editProfileViewDelegate?.showProfileStoreFailure()
            } else if let url = url.element, let imageUrl = url {
                self?.profileImageUrl = imageUrl
            }
        })
        .disposed(by: disposeBag)
        
        fileUseCase.isSuceessPost.subscribe({ [weak self] isSuccess in
            if let isSuccess = isSuccess.element, !isSuccess {
                self?.editProfileViewDelegate?.showProfileStoreFailure()
            }
        })
        .disposed(by: disposeBag)

        return Output(isAvailableNickname: isAvailableNickname, showImagePickerSign: showImagePickerSign, profile: profile)
    }
    
    func getUserProfile() {
        userUseCase.getUserProfile(nickname: UserDefaults.standard.getUserInfo(.nickname) ?? "")
    }
    
    func checkAvailableNickname(nickname: String) {
        userUseCase.checkUserNickname(nickname: nickname)
    }
    
    func updateUserInfo(updateInfo: [String: Any]) {
        userUseCase.updateUserInfo(userInfo: updateInfo)
    }
    
    func postToImagePresignedUrl(image: UIImage, imageType: String) {
        let fileExt = FileExt(fileExt: imageType)
        fileUseCase.createPresignedUrl(image: image, imageType: fileExt)
    }
    
    func checkAllOptions() -> Observable<Bool> {
        let nicknameObservable: Observable<Bool> = optionsRelay
            .map { $0["nickname"] as? Bool }
            .filter { $0 != nil }
            .compactMap { $0 }
        let genderObservable: Observable<Bool?> = optionsRelay
            .map { $0["gender"] as? Bool }
            .filter { $0 != nil }
            .compactMap { $0 }
        let bioObservable: Observable<Bool?> = optionsRelay
            .map { $0["bio"] as? Bool }
            .filter { $0 != nil }
            .compactMap { $0 }
        
        let isButtonEnabled = Observable.combineLatest(nicknameObservable, genderObservable, bioObservable, resultSelector: { nickname, gender, bio in
            return nickname && bio! && gender != nil
        })
        return isButtonEnabled
    }
    
    private func updateOption(_ key: String, with value: Any) {
        var currentOptions = optionsRelay.value
        if currentOptions.keys.contains(key) {
            currentOptions[key] = value
        } else {
            currentOptions.merge([key: value], uniquingKeysWith: { (_, new) in new })
        }
        optionsRelay.accept(currentOptions)
    }
    
    deinit {
        editProfileViewDelegate = nil
        disposeBag = DisposeBag()
    }
}
