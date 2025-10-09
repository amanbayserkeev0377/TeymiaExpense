import SwiftUI
import SwiftData

extension View {
    @ViewBuilder
    func fullScreenSheet<Content: View, Background: View>(
        ignoresSafeArea: Bool = false,
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping (UIEdgeInsets) -> Content,
        @ViewBuilder background: @escaping () -> Background
    ) -> some View {
        self
            .fullScreenCover(isPresented: isPresented) {
                FullScreenSheet(
                    ignoresSafeArea: ignoresSafeArea,
                    isPresented: isPresented,
                    content: content,
                    background: background
                )
            }
    }
}

fileprivate struct FullScreenSheet<Content: View, Background: View>: View {
    var ignoresSafeArea: Bool
    @Binding var isPresented: Bool
    @ViewBuilder var content: (UIEdgeInsets) -> Content
    @ViewBuilder var background: Background
    /// View Properties
    @Environment(\.dismiss) var dismiss
    @State private var offset: CGFloat = 0
    @State private var scrollDisabled: Bool = false
    @State private var isLoaded: Bool = false
    var body: some View {
        content(safeArea)
            .scrollDisabled(scrollDisabled)
            /// Test "geometryGroup" modifier with your use cases, and if there is any animation glitch try comment/uncomment it out!
            .geometryGroup()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(.rect)
            .offset(y: offset)
            .gesture(
                CustomPanGesture { gesture in
                    let state = gesture.state
                    let halfHeight = windowSize.height / 2
                    
                    let translation = min(max(gesture.translation(in: gesture.view).y, 0), windowSize.height)
                    let velocity = min(max(gesture.velocity(in: gesture.view).y / 5, 0), halfHeight)
                    
                    switch state {
                    case .began:
                        scrollDisabled = true
                        offset = translation
                    case .changed:
                        guard scrollDisabled else { return }
                        offset = translation
                    case .ended, .cancelled, .failed:
                        /// Disabling gesture until the animation get's completed
                        gesture.isEnabled = false
                        
                        if (translation + velocity) > halfHeight {
                            /// Closing and removing full-screen-cover
                            withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                                offset = windowSize.height
                            }
                            
                            Task {
                                try? await Task.sleep(for: .seconds(0.3))
                                var transaction = SwiftUI.Transaction() // "SwiftUI" because I have model Transaction
                                transaction.disablesAnimations = true
                                withTransaction(transaction) {
                                    dismiss()
                                }
                            }
                        } else {
                            /// Resetting
                            withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                                offset = 0
                            }
                            
                            Task {
                                try? await Task.sleep(for: .seconds(0.3))
                                scrollDisabled = false
                                gesture.isEnabled = true
                            }
                        }
                    default: ()
                    }
                }
            )
            .presentationBackground {
                background
                    /// Moving the background as well!
                    .offset(y: offset)
            }
            .ignoresSafeArea(.container, edges: ignoresSafeArea ? .all : [])
    }
    
    var windowSize: CGSize {
        if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow {
            return window.screen.bounds.size
        }
        
        return .zero
    }
    
    var safeArea: UIEdgeInsets {
        if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow {
            return window.safeAreaInsets
        }
        
        return .zero
    }
}

fileprivate struct CustomPanGesture: UIGestureRecognizerRepresentable {
    var handle: (UIPanGestureRecognizer) -> ()
    
    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }
    
    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let gesture = UIPanGestureRecognizer()
        gesture.delegate = context.coordinator
        return gesture
    }
    
    func updateUIGestureRecognizer(_ recognizer: UIPanGestureRecognizer, context: Context) {
        
    }
    
    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context: Context) {
        handle(recognizer)
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
                return false
            }
            
            /// Used to know the direction of the drag!
            let velocity = panGesture.velocity(in: panGesture.view).y
            var offset: CGFloat = 0
            
            if let cView = otherGestureRecognizer.view as? UICollectionView {
                offset = cView.contentOffset.y + cView.adjustedContentInset.top
            }
            
            if let sView = otherGestureRecognizer.view as? UIScrollView {
                offset = sView.contentOffset.y + sView.adjustedContentInset.top
            }
            
            let isElligible = Int(offset) <= 1 && velocity > 0
            
            return isElligible
        }
        
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            let status = (gestureRecognizer.view?.gestureRecognizers?.contains(where: {
                ($0.name ?? "").localizedStandardContains("zoom")
            })) ?? false
            
            return !status
        }
    }
}
