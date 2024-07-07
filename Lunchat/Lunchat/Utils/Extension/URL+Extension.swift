//
//  URL+Extension.swift
//  Lunchat
//
//  Created by 이경후 on 2/5/24.
//

import Foundation

extension URL {
    
    var parsedFileName: String? {
        let pathComponents = pathComponents.filter { !$0.isEmpty }
        if let lastPath = pathComponents.last, pathComponents.count >= 3 {
            return "\(pathComponents[pathComponents.count - 2])/\(lastPath)"
        }
        return nil
    }
    
    var parsedFileNameNotDownSampling: String? {
        let fileName = parsedFileName ?? ""
        return fileName + "NotDownSampling"
    }
}
