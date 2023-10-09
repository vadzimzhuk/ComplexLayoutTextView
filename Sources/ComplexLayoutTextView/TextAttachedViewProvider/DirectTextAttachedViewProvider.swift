import UIKit

final public class DirectTextAttachedViewProvider: TextAttachedViewProvider {

    lazy var view: UIView = {
        guard let viewBuilder else { assertionFailure(); return UIView() }
        return viewBuilder()
    }()

    public var viewBuilder: (() -> UIView)?

    public init(viewBuilder: (() -> UIView)? = nil) {
        self.viewBuilder = viewBuilder
    }

    /// Actually not instantiate but just return
    public func instantiateView(for attachment: SubviewTextAttachment, in behavior: SubviewAttachingTextViewBehavior) -> UIView {
        return self.view
    }

    public func getView() -> UIView {
        self.view
    }

    public func bounds(for attachment: SubviewTextAttachment, textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint) -> CGRect {
        return attachment.bounds
    }
}

