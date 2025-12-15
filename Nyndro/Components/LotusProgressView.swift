//
//  LotusProgressView.swift
//  Nyndro
//
//  Beautiful lotus flower progress visualization
//  Lotus blooms as progress increases, symbolizing spiritual growth
//

import SwiftUI

struct LotusProgressView: View {
    let progress: Double
    let color: Color
    var animate: Bool = false
    
    @State private var animatedProgress: Double = 0
    @State private var showPulse: Bool = false
    @State private var showCelebration: Bool = false
    
    // Number of petals
    private let petalCount = 8
    
    // Progress stages for lotus bloom
    private var bloomStage: BloomStage {
        switch progress {
        case 0..<0.125:
            return .bud
        case 0.125..<0.25:
            return .budOpening
        case 0.25..<0.5:
            return .halfOpen
        case 0.5..<0.75:
            return .threeQuarters
        case 0.75..<1.0:
            return .almostFull
        default:
            return .fullBloom
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            
            ZStack {
                // Water background
                waterBackground(size: size)
                
                // Lotus stem
                lotusStem(size: size)
                
                // Lotus petals
                lotusPetals(size: size)
                
                // Center with percentage
                lotusCenter(size: size)
                
                // Celebration overlay
                if showCelebration {
                    celebrationOverlay(size: size)
                }
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .onAppear {
            if animate {
                withAnimation(.easeOut(duration: 1.0)) {
                    animatedProgress = progress
                }
            } else {
                animatedProgress = progress
            }
            
            if progress >= 1.0 {
                withAnimation(.easeInOut(duration: 0.5).delay(0.5)) {
                    showCelebration = true
                }
            }
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedProgress = newValue
            }
            
            // Pulse on progress increase
            if newValue > oldValue {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showPulse = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showPulse = false
                }
            }
            
            // Celebration at completion
            if newValue >= 1.0 && oldValue < 1.0 {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showCelebration = true
                }
            }
        }
    }
    
    // MARK: - Water Background
    
    private func waterBackground(size: CGFloat) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.theme.lotusWater.opacity(0.3),
                        Color.theme.lotusWater.opacity(0.6)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 2
                )
            )
            .frame(width: size, height: size)
    }
    
    // MARK: - Lotus Stem
    
    private func lotusStem(size: CGFloat) -> some View {
        let stemHeight = size * 0.3 * min(animatedProgress * 2, 1.0)
        
        return Path { path in
            let controlOffset = size * 0.05
            path.move(to: CGPoint(x: size / 2, y: size / 2 + size * 0.15))
            path.addQuadCurve(
                to: CGPoint(x: size / 2, y: size / 2 + size * 0.15 + stemHeight),
                control: CGPoint(x: size / 2 + controlOffset, y: size / 2 + size * 0.15 + stemHeight / 2)
            )
        }
        .stroke(Color.theme.lotusStem, style: StrokeStyle(lineWidth: 4, lineCap: .round))
    }
    
    // MARK: - Lotus Petals
    
    private func lotusPetals(size: CGFloat) -> some View {
        ZStack {
            // Outer petals (background layer)
            ForEach(0..<petalCount, id: \.self) { index in
                let petalProgress = Double(index) / Double(petalCount)
                let isActive = animatedProgress >= petalProgress
                let angle = Double(index) * (360.0 / Double(petalCount)) - 90
                
                petalShape(size: size, isActive: isActive, petalIndex: index)
                    .fill(
                        isActive
                            ? AnyShapeStyle(LinearGradient(
                                colors: [color.opacity(0.7), color],
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                            : AnyShapeStyle(Color.theme.progressEmpty.opacity(0.3))
                    )
                    .rotationEffect(.degrees(angle))
                    .scaleEffect(showPulse && isActive ? 1.05 : 1.0)
            }
            
            // Inner petals (for depth)
            ForEach(0..<petalCount, id: \.self) { index in
                let petalProgress = Double(index) / Double(petalCount)
                let isActive = animatedProgress >= petalProgress
                let angle = Double(index) * (360.0 / Double(petalCount)) - 90 + 22.5
                
                if isActive {
                    innerPetalShape(size: size)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.5), color.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .rotationEffect(.degrees(angle))
                }
            }
        }
        .offset(y: -size * 0.05)
    }
    
    // MARK: - Petal Shapes
    
    private func petalShape(size: CGFloat, isActive: Bool, petalIndex: Int) -> some Shape {
        let openness = bloomStage.openness
        let petalLength = size * 0.35 * (isActive ? 1.0 : 0.7)
        let petalWidth = size * 0.15 * openness
        
        return PetalPath(length: petalLength, width: petalWidth, openness: openness)
    }
    
    private func innerPetalShape(size: CGFloat) -> some Shape {
        let openness = bloomStage.openness
        let petalLength = size * 0.25
        let petalWidth = size * 0.1 * openness
        
        return PetalPath(length: petalLength, width: petalWidth, openness: openness)
    }
    
    // MARK: - Lotus Center
    
    private func lotusCenter(size: CGFloat) -> some View {
        ZStack {
            // Center circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.3), color.opacity(0.6)],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.15
                    )
                )
                .frame(width: size * 0.3, height: size * 0.3)
            
            // Percentage text
            VStack(spacing: 2) {
                Text("\(Int(animatedProgress * 100))")
                    .font(.system(size: size * 0.12, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                
                Text("%")
                    .font(.system(size: size * 0.05, weight: .medium))
                    .foregroundColor(color.opacity(0.7))
            }
        }
        .offset(y: -size * 0.05)
    }
    
    // MARK: - Celebration Overlay
    
    private func celebrationOverlay(size: CGFloat) -> some View {
        ZStack {
            // Sparkles
            ForEach(0..<12, id: \.self) { index in
                let angle = Double(index) * 30
                let distance = size * 0.4
                
                Image(systemName: "sparkle")
                    .font(.system(size: size * 0.06))
                    .foregroundColor(color)
                    .offset(
                        x: cos(angle * .pi / 180) * distance,
                        y: sin(angle * .pi / 180) * distance
                    )
                    .opacity(showCelebration ? 1 : 0)
                    .scaleEffect(showCelebration ? 1 : 0.5)
            }
        }
    }
}

// MARK: - Bloom Stage

private enum BloomStage {
    case bud
    case budOpening
    case halfOpen
    case threeQuarters
    case almostFull
    case fullBloom
    
    var openness: Double {
        switch self {
        case .bud: return 0.3
        case .budOpening: return 0.5
        case .halfOpen: return 0.7
        case .threeQuarters: return 0.85
        case .almostFull: return 0.95
        case .fullBloom: return 1.0
        }
    }
}

// MARK: - Petal Path

private struct PetalPath: Shape {
    let length: CGFloat
    let width: CGFloat
    let openness: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let tipY = center.y - length
        
        // Petal shape using bezier curves
        path.move(to: center)
        
        // Left curve
        path.addQuadCurve(
            to: CGPoint(x: center.x, y: tipY),
            control: CGPoint(x: center.x - width, y: center.y - length * 0.6 * openness)
        )
        
        // Right curve (back to center)
        path.addQuadCurve(
            to: center,
            control: CGPoint(x: center.x + width, y: center.y - length * 0.6 * openness)
        )
        
        return path
    }
}

// MARK: - Preview

#Preview("Lotus Progress") {
    VStack(spacing: 40) {
        HStack(spacing: 20) {
            LotusProgressView(progress: 0.1, color: .blue)
                .frame(width: 100, height: 100)
            
            LotusProgressView(progress: 0.3, color: .purple)
                .frame(width: 100, height: 100)
            
            LotusProgressView(progress: 0.5, color: .pink)
                .frame(width: 100, height: 100)
        }
        
        HStack(spacing: 20) {
            LotusProgressView(progress: 0.75, color: .orange)
                .frame(width: 100, height: 100)
            
            LotusProgressView(progress: 0.9, color: .green)
                .frame(width: 100, height: 100)
            
            LotusProgressView(progress: 1.0, color: .red)
                .frame(width: 100, height: 100)
        }
        
        LotusProgressView(progress: 0.65, color: .indigo, animate: true)
            .frame(width: 200, height: 200)
    }
    .padding()
}
