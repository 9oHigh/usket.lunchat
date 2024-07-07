//
//  BaseViewModel.swift
//  Lunchat
//
//  Created by 이경후 on 2023/02/05.
//

import Foundation
import RxSwift

protocol BaseViewModel {
    
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get set }
    
    func transform(input: Input) -> Output
}
