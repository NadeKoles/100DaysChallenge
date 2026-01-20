//
//  FlowLayout.swift
//  100DaysChallenge
//
//  Wrapping flow layout for chips and tags
//

import SwiftUI

struct FlowLayout: Layout {
    var horizontalSpacing: CGFloat
    var verticalSpacing: CGFloat
    
    init(horizontalSpacing: CGFloat = Spacing.sm, verticalSpacing: CGFloat = Spacing.sm) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing
        )
        
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }
}

private struct FlowResult {
    var size: CGSize = .zero
    var frames: [CGRect] = []
    
    init(in maxWidth: CGFloat, subviews: LayoutSubviews, horizontalSpacing: CGFloat, verticalSpacing: CGFloat) {
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var frames: [CGRect] = []
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + verticalSpacing
                lineHeight = 0
            }
            
            frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + horizontalSpacing
        }
        
        self.frames = frames
        self.size = CGSize(
            width: maxWidth,
            height: currentY + lineHeight
        )
    }
}
