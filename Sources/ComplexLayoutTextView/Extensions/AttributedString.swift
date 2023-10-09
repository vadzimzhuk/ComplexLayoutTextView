import UIKit

public extension NSTextAttachment {

    convenience init(image: UIImage, size: CGSize? = nil) {
        self.init(data: nil, ofType: nil)

        self.image = image
        if let size = size {
            self.bounds = CGRect(origin: .zero, size: size)
        }
    }
}

public extension NSAttributedString {

    func insertingAttachment(_ attachment: NSTextAttachment, at index: Int, with paragraphStyle: NSParagraphStyle? = nil) -> NSAttributedString {
        let copy = self.mutableCopy() as! NSMutableAttributedString
        copy.insertAttachment(attachment, at: index, with: paragraphStyle)

        return copy.copy() as! NSAttributedString
    }

    func addingAttributes(_ attributes: [NSAttributedString.Key : Any]) -> NSAttributedString {
        let copy = self.mutableCopy() as! NSMutableAttributedString
        copy.addAttributes(attributes)

        return copy.copy() as! NSAttributedString
    }
}

public extension NSMutableAttributedString {

    func insertAttachment(_ attachment: NSTextAttachment, at index: Int, with paragraphStyle: NSParagraphStyle? = nil) {
        let plainAttachmentString = NSAttributedString(attachment: attachment)

        if let paragraphStyle = paragraphStyle {
            let attachmentString = plainAttachmentString
                .addingAttributes([ .paragraphStyle : paragraphStyle ])
            let separatorString = NSAttributedString(string: .paragraphSeparator)

            let insertion = NSMutableAttributedString()
            insertion.append(separatorString)
            insertion.append(attachmentString)
            insertion.append(separatorString)

            self.insert(insertion, at: index)
        } else {
            self.insert(plainAttachmentString, at: index)
        }
    }

    func addAttributes(_ attributes: [NSAttributedString.Key : Any]) {
        self.addAttributes(attributes, range: NSRange(location: 0, length: self.length))
    }
}

public extension String {
    static let paragraphSeparator = "\u{2029}"
}

public extension NSAttributedString {

    convenience init(data: Data) throws {
        try self.init(data: data,
                      options: [.documentType: NSAttributedString.DocumentType.rtfd],
                      documentAttributes: nil)
    }

    var attachments: [(attachment: Any, range: NSRange)] {
        var ranges: [(Any, NSRange)] = []

        let fullRange = NSRange(location: 0, length: self.length)

        self.enumerateAttribute(NSAttributedString.Key.attachment, in: fullRange) { value, range, _ in
            ranges.append((value as Any, range))
        }

        return ranges
    }

    var entireStringRange: NSRange {
        NSRange(string.startIndex..., in: string)
    }

    var asDataWithAttachments: Data? {
        let documentAttributes: [NSAttributedString.DocumentAttributeKey : Any] = [.documentType: NSAttributedString.DocumentType.rtfd]

        return try? data(from: entireStringRange, documentAttributes: documentAttributes)
    }
}

extension NSAttributedString {
    var subviewAttachmentRanges: [(attachment: SubviewTextAttachment, range: NSRange)] {
        let fullRange = NSRange(location: 0, length: self.length)
        var ranges = [(SubviewTextAttachment, NSRange)]()

        self.enumerateAttribute(NSAttributedString.Key.attachment, in: fullRange) { value, range, _ in
            if let attachment = value as? SubviewTextAttachment {
                ranges.append((attachment, range))
            }
        }

        return ranges
    }
}
