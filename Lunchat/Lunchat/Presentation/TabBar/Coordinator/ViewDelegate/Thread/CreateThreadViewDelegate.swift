//
//  CreateThreadViewDelegate.swift
//  Lunchat
//
//  Created by 이경후 on 1/9/24.
//

import Foundation

protocol CreateThreadViewDelegate: AnyObject {
    func showMapViewController(lat: Double, long: Double)
    func showInAccessableLocationView()
    func showMapChosenFailure()
    func showInfoViewController(locationInfo: SearchedPlace)
    func showPhotoUploadFailure()
    func showCreateThreadSuccess()
    func showCreateThreadFailure()
    func finishCreateThread()
    func getCreateThreadParm() -> RequestCreateThread
}
