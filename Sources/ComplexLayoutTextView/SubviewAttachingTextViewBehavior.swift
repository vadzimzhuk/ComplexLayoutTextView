import UIKit
import WebKit
import MapKit

public protocol AttachmentInteractor {
    func setupInteractionFor(attachment: RestorableSubviewTextAttachment)
}

/**
 Component class managing a text view behaviour that tracks all text attachments of SubviewTextAttachment class, automatically inserts/removes their views as text view subviews, and updates their layout according to the text view's layout manager.
 - Note: Follow the implementation of `SubviewAttachingTextView` for an example of adopting this behavior in your custom text view subclass.
 */
    @objc(VVSubviewAttachingTextViewBehavior)
open class SubviewAttachingTextViewBehavior: NSObject, NSLayoutManagerDelegate, NSTextStorageDelegate {

    public var viewInteractionHandler: AttachmentInteractor?

    open weak var textView: UITextView? {
        willSet {
            // Remove all managed subviews from the text view being disconnected
            self.removeAttachedSubviews()
        }
        didSet {
            // Synchronize managed subviews to the new text view
            self.updateAttachedSubviews()
            self.layoutAttachedSubviews()
        }
    }

    private let attachedViews = NSMapTable<TextAttachedViewProvider, UIView>.strongToStrongObjects()
    private var attachedProviders: Array<TextAttachedViewProvider> {
        return Array(self.attachedViews.keyEnumerator()) as! Array<TextAttachedViewProvider>
    }

    /**
     Adds attached views as subviews and removes subviews that are no longer attached. This method is called automatically when text view's text attributes change. Calling this method does not automatically perform a layout of attached subviews.
     */
    @objc
    open func updateAttachedSubviews() {
        guard let textView = self.textView else {
            return
        }

        // Collect all SubviewTextAttachment attachments
        let subviewAttachments = textView.textStorage.subviewAttachmentRanges.map { $0.attachment }

        // Remove views whose providers are no longer attached
        for provider in self.attachedProviders {
            if (subviewAttachments.contains { $0.viewProvider === provider } == false) {
                self.attachedViews.object(forKey: provider)?.removeFromSuperview()
                self.attachedViews.removeObject(forKey: provider)
            }
        }

        // Insert views that became attached
        let attachmentsToAdd = subviewAttachments.filter {
            self.attachedViews.object(forKey: $0.viewProvider) == nil
        }

        for attachment in attachmentsToAdd {
            let provider = attachment.viewProvider

            let view = provider.instantiateView(for: attachment, in: self)
            view.translatesAutoresizingMaskIntoConstraints = true
            view.autoresizingMask = [ ]

            if let viewInteractionHandler,
               let restorableAttachment = attachment as? RestorableSubviewTextAttachment {
                viewInteractionHandler.setupInteractionFor(attachment: restorableAttachment)
            }

            textView.addSubview(view)
            self.attachedViews.setObject(view, forKey: provider)
        }
    }

    private func removeAttachedSubviews() {
        for provider in self.attachedProviders {
            self.attachedViews.object(forKey: provider)?.removeFromSuperview()
        }
        self.attachedViews.removeAllObjects()
    }

    // MARK: Layout

    /**
     Lays out all attached subviews according to the layout manager. This method is called automatically when layout manager finishes updating its layout.
     */
    open func layoutAttachedSubviews() {
        guard let textView = self.textView else { return }

        let layoutManager = textView.layoutManager
        let scaleFactor = textView.window?.screen.scale ?? UIScreen.main.scale

        let attachmentRanges = textView.textStorage.subviewAttachmentRanges

        for (attachment, range) in attachmentRanges {
            guard let view = self.attachedViews.object(forKey: attachment.viewProvider) else { continue }

            guard view.superview === textView else { continue }

            guard let attachmentRect = SubviewAttachingTextViewBehavior.boundingRect(forAttachmentCharacterAt: range.location, layoutManager: layoutManager) else {
                view.isHidden = true
                continue
            }

            let convertedRect = textView.convertRectFromTextContainer(attachmentRect)
            let integralRect = CGRect(origin: convertedRect.origin.integral(withScaleFactor: scaleFactor),
                                      size: convertedRect.size)

            UIView.performWithoutAnimation {
                view.frame = integralRect
                view.isHidden = false
            }
        }
    }

    private static func boundingRect(forAttachmentCharacterAt characterIndex: Int, layoutManager: NSLayoutManager) -> CGRect? {
        let glyphRange = layoutManager.glyphRange(forCharacterRange: NSMakeRange(characterIndex, 1), actualCharacterRange: nil)
        let glyphIndex = glyphRange.location

        guard glyphIndex != NSNotFound && glyphRange.length == 1 else {
            return nil
        }

        let attachmentSize = layoutManager.attachmentSize(forGlyphAt: glyphIndex)

        guard attachmentSize.width > 0.0 && attachmentSize.height > 0.0 else {
            return nil
        }

        let lineFragmentRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: nil)
        let glyphLocation = layoutManager.location(forGlyphAt: glyphIndex)

        guard lineFragmentRect.width > 0.0 && lineFragmentRect.height > 0.0 else {
            return nil
        }

        return CGRect(origin: CGPoint(x: lineFragmentRect.minX + glyphLocation.x,
                                      y: lineFragmentRect.minY + glyphLocation.y - attachmentSize.height),
                      size: attachmentSize)
    }

    public func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        if layoutFinishedFlag {
            self.layoutAttachedSubviews()
        }
    }

    public func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        if editedMask.contains(.editedAttributes) {
            self.updateAttachedSubviews()
        }
    }

}
