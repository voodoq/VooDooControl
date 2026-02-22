//
//  Glass.swift
//  DesignSystem
//
//  Liquid Glass materials and effects
//

import SwiftUI

// MARK: - Glass Materials
enum GlassThickness {
    case ultraThin, thin, regular, thick, ultraThick
    
    var material: Material {
        switch self {
        case .ultraThin: .ultraThinMaterial
        case .thin: .thinMaterial
        case .regular: .regularMaterial
        case .thick: .thickMaterial
        case .ultraThick: .ultraThickMaterial
        }
    }
}

// MARK: - Glass Background Modifier
struct GlassBackgroundModifier: ViewModifier {
    let thickness: GlassThickness
    let shape: AnyShape
    
    func body(content: Content) -> some View {
        content
            .background(thickness.material)
            .clipShape(shape)
            .overlay(
                shape
                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
            )
            .shadow(
                color: Color.black.opacity(0.15),
                radius: 20,
                x: 0,
                y: 10
            )
    }
}

extension View {
    func glassBackground(_ thickness: GlassThickness = .regular, in shape: some Shape) -> some View {
        modifier(GlassBackgroundModifier(thickness: thickness, shape: AnyShape(shape)))
    }
    
    func glassCard(thickness: GlassThickness = .thick, cornerRadius: CGFloat = 24) -> some View {
        glassBackground(thickness, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
    
    func glassCapsule(thickness: GlassThickness = .thin) -> some View {
        glassBackground(thickness, in: Capsule())
    }
}

// MARK: - Glass Button Style
struct GlassButtonStyle: ButtonStyle {
    var thickness: GlassThickness = .thin
    var accentColor: Color = .accentColor
    var isProminent: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.medium)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Group {
                    if isProminent {
                        accentColor.opacity(configuration.isPressed ? 0.7 : 0.9)
                    } else {
                        thickness.material
                    }
                }
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isProminent ? Color.clear : Color.white.opacity(0.15), lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == GlassButtonStyle {
    static func glass(thickness: GlassThickness = .thin, accent: Color = .accentColor, prominent: Bool = false) -> GlassButtonStyle {
        GlassButtonStyle(thickness: thickness, accentColor: accent, isProminent: prominent)
    }
}

// MARK: - Glass Toggle Style
struct GlassToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            ZStack {
                Capsule()
                    .fill(configuration.isOn ? Color.accentColor.opacity(0.3) : Color.gray.opacity(0.2))
                    .frame(width: 52, height: 32)
                
                Circle()
                    .fill(configuration.isOn ? Color.accentColor : Color.white)
                    .frame(width: 28, height: 28)
                    .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    .offset(x: configuration.isOn ? 10 : -10)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isOn)
            }
            .onTapGesture {
                configuration.isOn.toggle()
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
            }
        }
    }
}

extension ToggleStyle where Self == GlassToggleStyle {
    static var glass: GlassToggleStyle { GlassToggleStyle() }
}

// MARK: - Glow Effect
struct GlowModifier: ViewModifier {
    var color: Color
    var radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.5), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.3), radius: radius * 2, x: 0, y: 0)
    }
}

extension View {
    func glow(color: Color = .accentColor, radius: CGFloat = 10) -> some View {
        modifier(GlowModifier(color: color, radius: radius))
    }
}

// MARK: - Glass Segmented Control
struct GlassSegmentedControl<Selection: Hashable>: View {
    let options: [Selection]
    let titles: (Selection) -> String
    @Binding var selection: Selection
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                Button(titles(option)) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selection = option
                    }
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }
                .buttonStyle(GlassSegmentButtonStyle(isSelected: selection == option))
            }
        }
        .padding(4)
        .background(.thinMaterial)
        .clipShape(Capsule())
    }
}

struct GlassSegmentButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(isSelected ? .semibold : .medium))
            .foregroundStyle(isSelected ? .primary : .secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.white.opacity(0.2) : Color.clear)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - AnyShape Helper
struct AnyShape: Shape {
    private let path: (CGRect) -> Path
    
    init<S: Shape>(_ shape: S) {
        self.path = { rect in shape.path(in: rect) }
    }
    
    func path(in rect: CGRect) -> Path {
        path(rect)
    }
}
