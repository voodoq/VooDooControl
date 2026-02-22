//
//  Animations.swift
//  DesignSystem
//
//  Liquid Glass animation presets
//

import SwiftUI

// MARK: - Animation Presets
extension Animation {
    /// Spring animation for UI interactions
    static var glassSpring: Animation {
        .spring(response: 0.4, dampingFraction: 0.8)
    }
    
    /// Quick spring for micro-interactions
    static var glassQuick: Animation {
        .spring(response: 0.2, dampingFraction: 0.7)
    }
    
    /// Bouncy spring for playful elements
    static var glassBounce: Animation {
        .spring(response: 0.5, dampingFraction: 0.6)
    }
    
    /// Smooth ease for transitions
    static var glassSmooth: Animation {
        .easeInOut(duration: 0.3)
    }
    
    /// Slow ease for emphasis
    static var glassSlow: Animation {
        .easeInOut(duration: 0.5)
    }
}

// MARK: - Transition Modifiers
struct GlassMoveTransition: ViewModifier {
    let edge: Edge
    
    func body(content: Content) -> some View {
        content
            .transition(
                .asymmetric(
                    insertion: .move(edge: edge).combined(with: .opacity),
                    removal: .move(edge: edge.opposite).combined(with: .opacity)
                )
            )
    }
}

extension View {
    func glassMove(edge: Edge) -> some View {
        modifier(GlassMoveTransition(edge: edge))
    }
}

extension Edge {
    var opposite: Edge {
        switch self {
        case .top: return .bottom
        case .bottom: return .top
        case .leading: return .trailing
        case .trailing: return .leading
        }
    }
}

// MARK: - Scale Transition
struct GlassScaleTransition: ViewModifier {
    func body(content: Content) -> some View {
        content
            .transition(
                .asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .opacity),
                    removal: .scale(scale: 0.95).combined(with: .opacity)
                )
            )
    }
}

extension View {
    func glassScale() -> some View {
        modifier(GlassScaleTransition())
    }
}

// MARK: - Parallax Effect
struct ParallaxModifier: ViewModifier {
    var amount: CGFloat = 10
    
    @State private var offset: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
            .offset(offset)
            .onAppear {
                withAnimation(.glassSpring.repeatForever(autoreverses: true)) {
                    offset = CGSize(width: amount, height: amount * 0.5)
                }
            }
    }
}

extension View {
    func parallax(amount: CGFloat = 10) -> some View {
        modifier(ParallaxModifier(amount: amount))
    }
}

// MARK: - Pulse Animation
struct PulseModifier: ViewModifier {
    var color: Color = .accentColor
    
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.6
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Circle()
                    .fill(color)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .allowsHitTesting(false)
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    scale = 1.5
                    opacity = 0
                }
            }
    }
}

extension View {
    func pulse(color: Color = .accentColor) -> some View {
        modifier(PulseModifier(color: color))
    }
}

// MARK: - Shake Animation (for errors)
struct ShakeModifier: ViewModifier {
    var trigger: Bool
    @State private var shakeOffset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(x: shakeOffset)
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    withAnimation(.spring(response: 0.1, dampingFraction: 0.3)) {
                        shakeOffset = 10
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.1, dampingFraction: 0.3)) {
                            shakeOffset = -10
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring(response: 0.1, dampingFraction: 0.3)) {
                            shakeOffset = 5
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.1, dampingFraction: 0.3)) {
                            shakeOffset = 0
                        }
                    }
                }
            }
    }
}

extension View {
    func shake(when trigger: Bool) -> some View {
        modifier(ShakeModifier(trigger: trigger))
    }
}

// MARK: - Loading Shimmer
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.3),
                            Color.white.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: -geo.size.width + (geo.size.width * 2 * phase))
                    .blendMode(.overlay)
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Hover Lift Effect
struct HoverLiftModifier: ViewModifier {
    @State private var isHovered: Bool = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .shadow(
                color: Color.black.opacity(isHovered ? 0.2 : 0.1),
                radius: isHovered ? 30 : 20,
                x: 0,
                y: isHovered ? 15 : 10
            )
            .animation(.glassSpring, value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

extension View {
    func hoverLift() -> some View {
        modifier(HoverLiftModifier())
    }
}
