//
//  MalaProgressView.swift
//  Nyndro
//
//  Traditional Buddhist mala (prayer beads) progress visualization
//  108 beads with guru bead at the bottom
//

import SwiftUI

struct MalaProgressView: View {
    let progress: Double
    let color: Color
    var animate: Bool = false
    
    @State private var animatedProgress: Double = 0
    @State private var pulsingBead: Int? = nil
    @State private var showCelebration: Bool = false
    
    // Mala configuration
    private let beadCount = 108
    private let guruBeadAngle: Double = 270 // Bottom position (6 o'clock)
    
    // Current filled bead count
    private var filledBeads: Int {
        Int(animatedProgress * Double(beadCount))
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            
            ZStack {
                // Background circle
                Circle()
                    .fill(Color.theme.secondaryBackground.opacity(0.3))
                    .frame(width: size, height: size)
                
                // Mala beads
                malaBeads(size: size)
                
                // Guru bead (larger bead at bottom)
                guruBead(size: size)
                
                // Center content
                centerContent(size: size)
                
                // Celebration effect
                if showCelebration {
                    celebrationEffect(size: size)
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
                triggerCelebration()
            }
        }
        .onChange(of: progress) { oldValue, newValue in
            let oldBeads = Int(oldValue * Double(beadCount))
            let newBeads = Int(newValue * Double(beadCount))
            
            withAnimation(.easeOut(duration: 0.3)) {
                animatedProgress = newValue
            }
            
            // Pulse newly filled beads
            if newBeads > oldBeads {
                pulsingBead = newBeads - 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    pulsingBead = nil
                }
            }
            
            // Celebration at completion
            if newValue >= 1.0 && oldValue < 1.0 {
                triggerCelebration()
            }
        }
    }
    
    // MARK: - Mala Beads
    
    private func malaBeads(size: CGFloat) -> some View {
        let radius = size * 0.4
        let beadSize = size * 0.035
        
        return ZStack {
            ForEach(0..<beadCount, id: \.self) { index in
                let angle = angleForBead(index)
                let isFilled = index < filledBeads
                let isPulsing = pulsingBead == index
                
                Circle()
                    .fill(beadColor(isFilled: isFilled, index: index))
                    .frame(width: beadSize, height: beadSize)
                    .shadow(color: isFilled ? color.opacity(0.3) : .clear, radius: 2)
                    .scaleEffect(isPulsing ? 1.5 : 1.0)
                    .offset(
                        x: cos(angle) * radius,
                        y: sin(angle) * radius
                    )
                    .animation(.easeOut(duration: 0.2), value: isFilled)
            }
        }
    }
    
    private func angleForBead(_ index: Int) -> Double {
        // Start from top and go clockwise
        let startAngle = -90.0 // 12 o'clock
        let anglePerBead = 360.0 / Double(beadCount)
        return (startAngle + Double(index) * anglePerBead) * .pi / 180
    }
    
    private func beadColor(isFilled: Bool, index: Int) -> Color {
        if isFilled {
            // Gradient effect - beads get slightly lighter as we go around
            let gradientFactor = 1.0 - (Double(index) / Double(beadCount)) * 0.2
            return color.opacity(0.7 + 0.3 * gradientFactor)
        } else {
            return Color.theme.malaBeadEmpty
        }
    }
    
    // MARK: - Guru Bead
    
    private func guruBead(size: CGFloat) -> some View {
        let radius = size * 0.4
        let guruSize = size * 0.06
        let angle = guruBeadAngle * .pi / 180
        
        let isComplete = animatedProgress >= 1.0
        
        return ZStack {
            // Guru bead body
            Circle()
                .fill(
                    isComplete
                        ? AnyShapeStyle(LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        : AnyShapeStyle(Color.theme.malaGuruBead)
                )
                .frame(width: guruSize, height: guruSize)
            
            // Tassel representation
            if isComplete {
                Rectangle()
                    .fill(color.opacity(0.6))
                    .frame(width: 2, height: size * 0.08)
                    .offset(y: guruSize / 2 + size * 0.04)
            }
        }
        .offset(
            x: cos(angle) * radius,
            y: sin(angle) * radius
        )
        .scaleEffect(isComplete ? 1.2 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isComplete)
    }
    
    // MARK: - Center Content
    
    private func centerContent(size: CGFloat) -> some View {
        VStack(spacing: size * 0.02) {
            // Filled count
            Text("\(filledBeads)")
                .font(.system(size: size * 0.15, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            // Total
            Text("/ \(beadCount)")
                .font(.system(size: size * 0.06, weight: .medium))
                .foregroundColor(Color.theme.textSecondary)
            
            // Percentage
            Text("\(Int(animatedProgress * 100))%")
                .font(.system(size: size * 0.05, weight: .regular))
                .foregroundColor(Color.theme.textTertiary)
                .padding(.top, size * 0.02)
        }
    }
    
    // MARK: - Celebration Effect
    
    private func celebrationEffect(size: CGFloat) -> some View {
        ZStack {
            // Pulsing ring
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 2)
                .frame(width: size * 0.85, height: size * 0.85)
                .scaleEffect(showCelebration ? 1.1 : 1.0)
                .opacity(showCelebration ? 0 : 1)
            
            // Inner glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.2), .clear],
                        center: .center,
                        startRadius: size * 0.1,
                        endRadius: size * 0.4
                    )
                )
                .frame(width: size * 0.8, height: size * 0.8)
        }
        .animation(
            .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
            value: showCelebration
        )
    }
    
    // MARK: - Helpers
    
    private func triggerCelebration() {
        withAnimation(.easeInOut(duration: 0.5)) {
            showCelebration = true
        }
    }
}

// MARK: - Compact Mala View (for cards)

struct CompactMalaView: View {
    let progress: Double
    let color: Color
    
    private let segments = 27 // Simplified for compact view
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            
            ZStack {
                // Background track
                Circle()
                    .stroke(Color.theme.progressEmpty, lineWidth: size * 0.08)
                
                // Progress arc
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        color,
                        style: StrokeStyle(
                            lineWidth: size * 0.08,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                
                // Bead markers
                ForEach(0..<segments, id: \.self) { index in
                    let angle = (Double(index) / Double(segments)) * 360 - 90
                    let isFilled = Double(index) / Double(segments) <= progress
                    
                    Circle()
                        .fill(isFilled ? color : Color.theme.malaBeadEmpty)
                        .frame(width: size * 0.06, height: size * 0.06)
                        .offset(y: -size * 0.4)
                        .rotationEffect(.degrees(angle))
                }
                
                // Percentage in center
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size * 0.2, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}

// MARK: - Preview

#Preview("Mala Progress") {
    VStack(spacing: 40) {
        HStack(spacing: 20) {
            MalaProgressView(progress: 0.1, color: .blue)
                .frame(width: 100, height: 100)
            
            MalaProgressView(progress: 0.33, color: .purple)
                .frame(width: 100, height: 100)
            
            MalaProgressView(progress: 0.5, color: .pink)
                .frame(width: 100, height: 100)
        }
        
        HStack(spacing: 20) {
            MalaProgressView(progress: 0.75, color: .orange)
                .frame(width: 100, height: 100)
            
            MalaProgressView(progress: 0.9, color: .green)
                .frame(width: 100, height: 100)
            
            MalaProgressView(progress: 1.0, color: .red)
                .frame(width: 100, height: 100)
        }
        
        MalaProgressView(progress: 0.65, color: .indigo, animate: true)
            .frame(width: 200, height: 200)
    }
    .padding()
}
