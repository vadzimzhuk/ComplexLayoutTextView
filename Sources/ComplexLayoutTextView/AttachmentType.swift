//
//  File.swift
//  
//
//  Created by Vadim Zhuk on 26/09/2023.
//

import UIKit

public enum AttachmentType: Codable {
    case image(Data) // TODO: - switch Data to UIImage
    case lp(URL)

    func asData() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    func asUIView() -> UIView {
        switch self {
            case .image(let data):
                let imageView = UIImageView(image: UIImage(data: data))
                return imageView
            case .lp(let url):
                return (try? RestorableSubviewTextAttachment.prepareLPView(url: url)) ?? UIView()
        }
    }

    static func from(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        return try decoder.decode(AttachmentType.self, from: data)
    }

    @available(*, deprecated, message: "Do not use furthermore")
    static func from(view: UIView) -> Self {
        switch view {
            case is UIImageView:
                if let imageView = view as? UIImageView,
                   let data = imageView.image?.pngData() {
                    return .image(data)
                }
                return .image(Data())
            default:
                fatalError()
        }
    }
}
