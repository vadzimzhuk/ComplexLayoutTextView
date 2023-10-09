//
//  RestorableSubviewTextAttachment.swift
//  SubviewAttachingTextView
//

import UIKit
import LinkPresentation
import MapKit

open class RestorableSubviewTextAttachment: SubviewTextAttachment, RestorableTextAttachment {

    public typealias Context = AttachmentContext

    public var attachmentType: AttachmentType

    /// View and it's parameters won't be archived if the attachment type doesn't cover it
    public init(view: @autoclosure () -> UIView, size: CGSize) {
        let view = view()
        attachmentType = AttachmentType.from(view: view)
        let provider = DirectTextAttachedViewProvider(viewBuilder: { view })
        super.init(viewProvider: provider)

        self.bounds = CGRect(origin: .zero, size: size != .zero ? size : view.textAttachmentFittingSize)
    }

    /// Initialize attachment by its type. The attachment view will be generated based on its type. All the tunning should be applied afterwards.
    public init(type: AttachmentType, size: CGSize) {
        attachmentType = type
        let provider = DirectTextAttachedViewProvider()
        super.init(viewProvider: provider)
        provider.viewBuilder = {self.viewFor(type: type)}

    }

    /// Initialize attachment from the archived Context.
    public required init(from context: Context) {
        let provider = DirectTextAttachedViewProvider()
        self.attachmentType = context.attachmentType

        super.init(viewProvider: provider)
        provider.viewBuilder = { self.viewFor(type: context.attachmentType) }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func viewFor(type: AttachmentType) -> UIView {
        let view: UIView

        switch type {
            case .image(let data):
                view = UIImageView(image: UIImage(data: data))
            case .lp(let url):
                view = (try? RestorableSubviewTextAttachment.prepareLPView(url: url)) ?? UIView()
        }

        self.bounds = CGRect(origin: .zero, size: view.textAttachmentFittingSize)
        return view
    }

    public static func createContext(from attachment: Any, at location: Int) throws -> Context {
        try .init(from: attachment, at: location)
    }

    static func prepareLPView(url: URL) throws -> UIView {
        let previewSize = CGSize(width: UIScreen.main.bounds.width - 10, height: 100)
        let container = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: previewSize))
        let secureUrl = try url.withReplacedScheme()

        let metadataProvider = LPMetadataProvider()

        metadataProvider.startFetchingMetadata(for: secureUrl) { metadata, error in
                if error == nil,
                   let metadata {
                    let linkView = LPLinkView(metadata: metadata)

                    DispatchQueue.main.async {
                        container.addSubview(linkView)
                        linkView.frame = CGRect(origin: container.bounds.origin, size: previewSize)
                    }
                }
        }

        return container
    }
}

    // MARK: - AttachmentContext
public struct AttachmentContext: RestorableTextAttachmentContext {

    public typealias Attachment = RestorableSubviewTextAttachment

    let attachmentType: AttachmentType
    public let location: Int

    init(attachmentType: AttachmentType, location: Int) {
        self.attachmentType = attachmentType
        self.location = location
    }

    init(from attachment: Any, at location: Int) throws {
        switch attachment {
            case let attachment as Attachment:
                self.init(from: attachment, at: location)
            default:
                throw NSError(domain: "", code: 0)
        }
    }

    public init(from attachment: Attachment, at location: Int) {
        self.attachmentType = attachment.attachmentType
        self.location = location
    }
}

private extension UIView {

    var textAttachmentFittingSize: CGSize {
        let fittingSize = self.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if fittingSize.width > 1e-3 && fittingSize.height > 1e-3 {
            return fittingSize
        } else {
            return self.bounds.size
        }
    }
}
