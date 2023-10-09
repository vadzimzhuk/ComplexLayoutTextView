//
//  SubviewTextAttachment.swift
//  SubviewAttachingTextView
//

import UIKit

/**
 Describes a custom text attachment object containing a view. SubviewAttachingTextViewBehavior tracks attachments of this class and automatically manages adding and removing subviews in its text view.
 */
open class SubviewTextAttachment: NSTextAttachment {

    public let viewProvider: TextAttachedViewProvider

    /**
     Initialize the attachment with a view provider.
     */
    public init(viewProvider: TextAttachedViewProvider) {
        self.viewProvider = viewProvider
        super.init(data: nil, ofType: nil)
    }

    /**
     Initialize the attachment with a view and an explicit size.
     - Warning: If an attributed string that includes the returned attachment is used in more than one text view at a time, the behavior is not defined.
     */
    public convenience init(view: UIView, size: CGSize) {
        let provider = DirectTextAttachedViewProvider(viewBuilder: {view})
        self.init(viewProvider: provider)
        self.bounds = CGRect(origin: .zero, size: size)
    }

    /**
     Initialize the attachment with a view and use its current fitting size as the attachment size.
     - Note: If the view does not define a fitting size, its current bounds size is used.
     - Warning: If an attributed string that includes the returned attachment is used in more than one text view at a time, the behavior is not defined.
     */
    public convenience init(view: UIView) {
        self.init(view: view, size: view.textAttachmentFittingSize)
    }

    open override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        return self.viewProvider.bounds(for: self, textContainer: textContainer, proposedLineFragment: lineFrag, glyphPosition: position)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("SubviewTextAttachment cannot be decoded.")
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
