//
//  RestorableAttributedString.swift
//  Demo
//

import UIKit

public struct RestorableAttributedString<Attachment: RestorableTextAttachment>: Codable {

    typealias AttachmentContext = Attachment.Context

    public let attributedString: NSMutableAttributedString

    var attachments: [AttachmentContext] {
        attributedString.attachments.compactMap { try? Attachment.createContext(from: $0.attachment, at: $0.range.location)}
    }

    enum CodingKeys: String, CodingKey {
        case attributedString
        case attachments
    }

    enum AttachmentsInfoKeys: String, CodingKey {
        case attachments
    }

    public init(attributedString: NSMutableAttributedString) {
        self.attributedString = attributedString
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let contexts = try values.decode([AttachmentContext].self, forKey: .attachments)
        let attributedStringData = try values.decode(Data.self, forKey: .attributedString)
        let restoredAttributedString = NSMutableAttributedString(attributedString: try NSAttributedString(data: attributedStringData))

        contexts.forEach { (context: AttachmentContext) in
            let attachment = Attachment(from: context)
            let attachmentString = NSMutableAttributedString(attachment: attachment)
            restoredAttributedString.insert(attachmentString,
                                                 at: context.location)}
        attributedString = restoredAttributedString
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(attributedString.asDataWithAttachments, forKey: .attributedString)
        try container.encode(attachments, forKey: .attachments)
    }
}
