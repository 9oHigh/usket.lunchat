//
//  UIImageView+Extension.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/23.
//

import UIKit.UIImageView
import RxSwift

// MARK: - RxImage

extension UIImageView {
    
    var rxImage: Observable<UIImage?> {
        return Observable.create { [weak self] observer in
            let observerToken = self?.observe(\.image, options: [.new, .old]) { (_, change) in
                if let newImage = change.newValue as? UIImage {
                    observer.onNext(newImage)
                }
            }
            
            return Disposables.create {
                observerToken?.invalidate()
            }
        }
    }
}

// MARK: - Image Caching & DownSampling

extension UIImageView {
    
    private static var imageCache = NSCache<NSString, UIImage>()
    
    private var activityIndicator: UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.tintColor = AppColor.purple.color
        return indicator
    }
    
    static func configureCachePolicy(with maximumBytes: Int) {
        UIImageView.imageCache.totalCostLimit = maximumBytes
    }
    
    private func addIndicator(indicator: UIActivityIndicatorView) {
        addSubview(indicator)
        indicator.snp.makeConstraints { $0.center.equalToSuperview() }
        indicator.startAnimating()
    }
    
    private func removeIndicator(indicator: UIActivityIndicatorView) {
        DispatchQueue.main.async {
            indicator.stopAnimating()
            indicator.removeFromSuperview()
        }
    }
    
    func loadImageFromUrl(url: URL?, isDownSampling: Bool = true) {
        guard let url = url else { return }
        
        let indicator = activityIndicator
        addIndicator(indicator: indicator)
        
        if let cachedImage = getCachedImage(for: url, isDownSampling: isDownSampling) {
            removeIndicator(indicator: indicator)
            self.image = cachedImage
        } else {
            downloadImage(from: url, isDownSampling: isDownSampling) { [weak self] in
                self?.removeIndicator(indicator: indicator)
            }
        }
    }
    
    private func getCachedImage(for url: URL, isDownSampling: Bool) -> UIImage? {
        
        if url.absoluteString.contains("default/profile") {
            return UIImageView.imageCache.object(forKey: "default/profile")
        } else {
            if isDownSampling {
                guard let cacheKey = url.parsedFileName as? NSString 
                else { return nil }
                return UIImageView.imageCache.object(forKey: cacheKey)
            } else {
                guard let cacheKey = url.parsedFileNameNotDownSampling as? NSString 
                else { return nil }
                return UIImageView.imageCache.object(forKey: cacheKey)
            }
        }
    }
    
    private func downloadImage(from url: URL, isDownSampling: Bool, completion: @escaping () -> Void) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                completion()
                return
            }
            
            DispatchQueue.main.async {
                if isDownSampling, let downsampledImage = self?.downsample(imageData: data, to: self?.bounds.size) {
                    self?.cacheAndSetImage(downsampledImage, for: url, isDown: true)
                } else {
                    guard let image = UIImage(data: data) else { return }
                    self?.cacheAndSetImage(image, for: url, isDown: false)
                }
                completion()
            }
        }.resume()
    }
    
    private func downsample(imageData: Data, to targetSize: CGSize?) -> UIImage? {
        guard let targetSize = targetSize else { return nil }
        
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: false,
            kCGImageSourceThumbnailMaxPixelSize: max(targetSize.width, targetSize.height) * 4
        ]
        
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil),
              let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil),
              let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
        else {
            return nil
        }
        
        // 이미지 프로퍼티에서 기존 속성 중 orientation이 의도와 다른 경우가 있음.
        var orientation: UIImage.Orientation = .up
        
        if let exifOrientation = (imageProperties as NSDictionary)[kCGImagePropertyOrientation] as? UInt32 {
            switch exifOrientation {
            case 1:
                orientation = .up
            case 3:
                orientation = .down
            case 8:
                orientation = .left
            case 6:
                orientation = .right
            default:
                orientation = .up
            }
        }
        
        return UIImage(cgImage: cgImage, scale: 1.0, orientation: orientation)
    }

    
    private func cacheAndSetImage(_ image: UIImage, for url: URL, isDown: Bool) {
        
        UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.image = image
        }, completion: nil)

        if url.absoluteString.contains("default/profile") {
            UIImageView.imageCache.setObject(image, forKey: "default/profile")
        } else {
            if isDown {
                guard let cacheKey = url.parsedFileName as? NSString else { return }
                UIImageView.imageCache.setObject(image, forKey: cacheKey)
            } else {
                guard let cacheKey = url.parsedFileNameNotDownSampling as? NSString else { return }
                UIImageView.imageCache.setObject(image, forKey: cacheKey)
            }
        }
    }
}
