//
//  File.swift
//  
//
//  Created by Vadim Zhuk on 26/09/2023.
//

import Foundation

extension URL {
    func withReplacedScheme(_ scheme: String = "https") throws -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.scheme = scheme

        guard let secureUrl = components?.url else { throw NSError(domain: "1", code: 1) }

        return secureUrl
    }
}
