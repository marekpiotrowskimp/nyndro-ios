//
//  MalaProgressView.swift
//  Nyndro
//
//  Traditional Buddhist mala (prayer beads) progress visualization
//  27 beads with guru bead and tassel at the bottom
//

import SwiftUI

struct MalaProgressView: View {
    let progress: Double
    let color: Color
    var animate: Bool = false
    
    @State private var animatedProgress: Double = 0
    @State private var pulsingBead: Int? = nil
    @State private var showCelebration: Bool = false
    
    // Mala configuration - 27 beads (traditional smaller mala)
    private let beadCount = 27
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
                
                // Guru bead with tassel (larger bead at bottom)
                guruBeadWithTassel(size: size)
                
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
        let radius = size * 0.35
        let beadSize = size * 0.08
        
        return ZStack {
            ForEach(0..<beadCount, id: \.self) { index in
                let angle = angleForBead(index)
                let isFilled = index < filledBeads
                let isPulsing = pulsingBead == index
                
                Circle()
                    .fill(beadColor(isFilled: isFilled, index: index))
                    .frame(width: beadSize, height: beadSize)
                    .shadow(color: isFilled ? color.opacity(0.4) : .clear, radius: 3)
                    .scaleEffect(isPulsing ? 1.4 : 1.0)
                    .offset(
                        x: cos(angle) * radius,
                        y: sin(angle) * radius
                    )
                    .animation(.easeOut(duration: 0.2), value: isFilled)
            }
        }
    }
    
    private func angleForBead(_ index: Int) -> Double {
        // Start from top and go clockwise, leaving gap at bottom for guru bead
        let startAngle = -90.0 // 12 o'clock
        // Leave space at bottom for guru bead (skip about 1.5 bead positions)
        let totalAngle = 330.0 // 360 - 30 degrees gap for guru bead area
        let anglePerBead = totalAngle / Double(beadCount)
        return (startAngle + Double(index) * anglePerBead + 15) * .pi / 180
    }
    
    private func beadColor(isFilled: Bool, index: Int) -> Color {
        if isFilled {
            // Gradient effect - beads get slightly lighter as we go around
            let gradientFactor = 1.0 - (Double(index) / Double(beadCount)) * 0.15
            return color.opacity(0.75 + 0.25 * gradientFactor)
        } else {
            return Color.theme.malaBeadEmpty
        }
    }
    
    // MARK: - Guru Bead with Tassel
    
    private func guruBeadWithTassel(size: CGFloat) -> some View {
        let radius = size * 0.35
        let guruSize = size * 0.12 // 2x larger than regular beads
        let angle = guruBeadAngle * .pi / 180
        let guruX = cos(angle) * radius
        let guruY = sin(angle) * radius
        
        let isComplete = animatedProgress >= 1.0
        let tasselLength = size * 0.12 // 12% of view height
        let smallBeadSize = size * 0.035 // Small decorative beads
        
        return ZStack {
            // Tassel - always visible, 2 threads
            tasselView(
                size: size,
                guruY: guruY,
                guruSize: guruSize,
                tasselLength: tasselLength,
                smallBeadSize: smallBeadSize,
                isComplete: isComplete
            )
            
            // Guru bead body - same color as practice
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            isComplete ? color : color.opacity(0.6),
                            isComplete ? color.opacity(0.8) : color.opacity(0.4)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: guruSize, height: guruSize)
                .shadow(color: color.opacity(0.4), radius: isComplete ? 6 : 3)
                .offset(x: guruX, y: guruY)
                .scaleEffect(isComplete ? 1.15 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: isComplete)
            
            // Guru bead inner highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.4), Color.clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: guruSize * 0.5
                    )
                )
                .frame(width: guruSize * 0.8, height: guruSize * 0.8)
                .offset(x: guruX - guruSize * 0.1, y: guruY - guruSize * 0.1)
        }
    }
    
    // MARK: - Tassel View
    
    private func tasselView(
        size: CGFloat,
        guruY: CGFloat,
        guruSize: CGFloat,
        tasselLength: CGFloat,
        smallBeadSize: CGFloat,
        isComplete: Bool
    ) -> some View {
        let threadSpacing = size * 0.025 // Space between two threads
        let startY = guruY + guruSize / 2
        
        return ZStack {
            // Left thread
            tasselThread(
                xOffset: -threadSpacing,
                startY: startY,
                tasselLength: tasselLength,
                smallBeadSize: smallBeadSize,
                isComplete: isComplete
            )
            
            // Right thread
            tasselThread(
                xOffset: threadSpacing,
                startY: startY,
                tasselLength: tasselLength,
                smallBeadSize: smallBeadSize,
                isComplete: isComplete
            )
        }
    }
    
    private func tasselThread(
        xOffset: CGFloat,
        startY: CGFloat,
        tasselLength: CGFloat,
        smallBeadSize: CGFloat,
        isComplete: Bool
    ) -> some View {
        let midBeadY = startY + tasselLength * 0.4
        let endBeadY = startY + tasselLength
        
        return ZStack {
            // Thread line
            Path { path in
                path.move(to: CGPoint(x: xOffset, y: startY))
                path.addLine(to: CGPoint(x: xOffset, y: startY + tasselLength))
            }
            .stroke(
                color.opacity(isComplete ? 0.8 : 0.5),
                style: StrokeStyle(lineWidth: 2, lineCap: .round)
            )
            
            // Middle decorative bead
            Circle()
                .fill(color.opacity(isComplete ? 0.9 : 0.6))
                .frame(width: smallBeadSize, height: smallBeadSize)
                .shadow(color: color.opacity(0.3), radius: 1)
                .offset(x: xOffset, y: midBeadY)
            
            // End decorative bead (slightly larger)
            Circle()
                .fill(color.opacity(isComplete ? 1.0 : 0.7))
                .frame(width: smallBeadSize * 1.2, height: smallBeadSize * 1.2)
                .shadow(color: color.opacity(0.3), radius: 2)
                .offset(x: xOffset, y: endBeadY)
        }
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
    
    private let segments = 27 // Matching main mala view
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let guruSize = size * 0.1
            let tasselLength = size * 0.12
            let smallBeadSize = size * 0.03
            
            ZStack {
                // Background track
                Circle()
                    .stroke(Color.theme.progressEmpty, lineWidth: size * 0.08)
                
                // Progress arc (leave gap at bottom for guru bead)
                Circle()
                    .trim(from: 0.042, to: 0.042 + progress * 0.916) // Gap of ~30 degrees
                    .stroke(
                        color,
                        style: StrokeStyle(
                            lineWidth: size * 0.08,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                
                // Guru bead at bottom
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.8), color.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: guruSize, height: guruSize)
                    .shadow(color: color.opacity(0.3), radius: 2)
                    .offset(y: size * 0.4)
                
                // Simplified tassel (2 threads)
                compactTassel(
                    size: size,
                    guruSize: guruSize,
                    tasselLength: tasselLength,
                    smallBeadSize: smallBeadSize
                )
                
                // Percentage in center
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size * 0.2, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
    
    private func compactTassel(
        size: CGFloat,
        guruSize: CGFloat,
        tasselLength: CGFloat,
        smallBeadSize: CGFloat
    ) -> some View {
        let startY = size * 0.4 + guruSize / 2
        let threadSpacing = size * 0.02
        
        return ZStack {
            // Left thread
            Path { path in
                path.move(to: CGPoint(x: -threadSpacing, y: startY))
                path.addLine(to: CGPoint(x: -threadSpacing, y: startY + tasselLength))
            }
            .stroke(color.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
            
            // Right thread
            Path { path in
                path.move(to: CGPoint(x: threadSpacing, y: startY))
                path.addLine(to: CGPoint(x: threadSpacing, y: startY + tasselLength))
            }
            .stroke(color.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
            
            // End beads
            Circle()
                .fill(color.opacity(0.7))
                .frame(width: smallBeadSize, height: smallBeadSize)
                .offset(x: -threadSpacing, y: startY + tasselLength)
            
            Circle()
                .fill(color.opacity(0.7))
                .frame(width: smallBeadSize, height: smallBeadSize)
                .offset(x: threadSpacing, y: startY + tasselLength)
        }
        .offset(x: size / 2, y: 0)
    }
}

// MARK: - Preview

#Preview("Mala Progress") {
    VStack(spacing: 40) {
        HStack(spacing: 20) {
            MalaProgressView(progress: 0.1, color: .blue)
                .frame(width: 120, height: 120)
            
            MalaProgressView(progress: 0.33, color: .purple)
                .frame(width: 120, height: 120)
            
            MalaProgressView(progress: 0.5, color: .pink)
                .frame(width: 120, height: 120)
        }
        
        HStack(spacing: 20) {
            MalaProgressView(progress: 0.75, color: .orange)
                .frame(width: 120, height: 120)
            
            MalaProgressView(progress: 0.9, color: .green)
                .frame(width: 120, height: 120)
            
            MalaProgressView(progress: 1.0, color: .red)
                .frame(width: 120, height: 120)
        }
        
        MalaProgressView(progress: 0.65, color: .indigo, animate: true)
            .frame(width: 200, height: 200)
        
        // Compact views
        HStack(spacing: 20) {
            CompactMalaView(progress: 0.3, color: .blue)
                .frame(width: 60, height: 60)
            
            CompactMalaView(progress: 0.7, color: .purple)
                .frame(width: 60, height: 60)
            
            CompactMalaView(progress: 1.0, color: .green)
                .frame(width: 60, height: 60)
        }
    }
    .padding()
}
