//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public final class BottomSheetTransitioningDelegate: NSObject {
    public private(set) var contentHeights: [CGFloat]
    private var startTargetIndex: Int
    private let handleBackground: BottomSheetView.HandleBackground
    private let draggableHeight: CGFloat?
    private let useSafeAreaInsets: Bool
    private let stretchOnResize: Bool
    private let userInterfaceStyle: UIUserInterfaceStyle?
    private let includeDimView: Bool
    private var weakPresentationController: WeakRef<BottomSheetPresentationController>?
    private weak var presentationDelegate: BottomSheetPresentationControllerDelegate?
    private weak var animationDelegate: BottomSheetViewAnimationDelegate?

    private var presentationController: BottomSheetPresentationController? {
        return weakPresentationController?.value
    }

    public var backgroundOverlayColor: UIColor? {
        presentationController?.dimViewBackgroundColor
    }

    // MARK: - Init

    public init(
        contentHeights: [CGFloat],
        startTargetIndex: Int = 0,
        handleBackground: BottomSheetView.HandleBackground = .color(.clear),
        draggableHeight: CGFloat? = nil,
        presentationDelegate: BottomSheetPresentationControllerDelegate? = nil,
        animationDelegate: BottomSheetViewAnimationDelegate? = nil,
        useSafeAreaInsets: Bool = false,
        stretchOnResize: Bool = false,
        userInterfaceStyle: UIUserInterfaceStyle? = nil,
        includeDimView: Bool = true
    ) {
        self.contentHeights = contentHeights
        self.startTargetIndex = startTargetIndex
        self.handleBackground = handleBackground
        self.draggableHeight = draggableHeight
        self.presentationDelegate = presentationDelegate
        self.animationDelegate = animationDelegate
        self.useSafeAreaInsets = useSafeAreaInsets
        self.stretchOnResize = stretchOnResize
        self.userInterfaceStyle = userInterfaceStyle
        self.includeDimView = includeDimView
    }

    // MARK: - Public

    /// Animates bottom sheet view to the given height.
    ///
    /// - Parameters:
    ///   - index: the index of the target height
    public func transition(to index: Int) {
        presentationController?.transition(to: index)
    }

    /// Recalculates target offsets and animates to the minimum one.
    /// Call this method e.g. when orientation change is detected.
    public func reset() {
        presentationController?.reset()
    }

    public func reload(with contentHeights: [CGFloat]) {
        let previousHeight = self.contentHeights[safe: startTargetIndex] ?? 0
        let indexOfPreviousHeightInNewHeights = contentHeights.firstIndex(of: previousHeight) ?? 0
        self.contentHeights = contentHeights
        startTargetIndex = indexOfPreviousHeightInNewHeights
        presentationController?.reload(with: contentHeights, targetIndex: startTargetIndex)
    }

    public func hideBackgroundOverlay() {
        presentationController?.hideDimView()
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension BottomSheetTransitioningDelegate: UIViewControllerTransitioningDelegate {
    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let presentationController = BottomSheetPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            contentHeights: contentHeights,
            startTargetIndex: startTargetIndex,
            presentationDelegate: presentationDelegate,
            animationDelegate: animationDelegate,
            handleBackground: handleBackground,
            draggableHeight: draggableHeight,
            useSafeAreaInsets: useSafeAreaInsets,
            stretchOnResize: stretchOnResize,
            userInterfaceStyle: userInterfaceStyle,
            includeDimView: includeDimView
        )
        self.weakPresentationController = WeakRef(value: presentationController)
        return presentationController
    }

    public func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        presentationController?.transitionState = .presenting
        return presentationController
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentationController?.transitionState = .dismissing
        return presentationController
    }

    public func interactionControllerForPresentation(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        return presentationController
    }
}

// MARK: - Private types

private class WeakRef<T> where T: AnyObject {
    private(set) weak var value: T?

    init(value: T?) {
        self.value = value
    }
}
