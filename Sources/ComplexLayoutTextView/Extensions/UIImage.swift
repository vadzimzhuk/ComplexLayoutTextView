//
//  UIView+Extensions.swift
//  SubviewAttachingTextView
//

import UIKit

extension UIImageView {
    var copy: UIImageView {
        guard let cgImage = image?.cgImage else { return UIImageView(image: UIImage.generalPlaceholder)}

        return UIImageView(image: UIImage(cgImage: cgImage))
    }
}

extension UIImage {
    static var generalPlaceholder: UIImage {
        UIImage(systemName: "photo")!
    }
}
