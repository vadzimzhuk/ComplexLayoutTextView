//
//  RestorableTextAttachmentProtocols.swift
//  SubviewAttachingTextView
//

import UIKit

public protocol RestorableTextAttachmentContext: Codable {

    associatedtype Attachment: RestorableTextAttachment

    init(from attachment: Attachment, at location: Int)

    var location: Int { get }
}

public protocol RestorableTextAttachment: NSTextAttachment {

    associatedtype Context: RestorableTextAttachmentContext

    init(from context: Context)

    static func createContext(from attachment: Any, at location: Int) throws -> Context
}
