//
//  Typography.swift
//  100DaysChallenge
//
//  Typography design tokens
//

import SwiftUI
import UIKit

extension Font {
    // MARK: - Display
    static let displayLarge = Font.system(size: 48, weight: .medium, design: .default)
    static let displayMedium = Font.system(size: 36, weight: .medium, design: .default)
    static let displaySmall = Font.system(size: 30, weight: .medium, design: .default)
    
    // MARK: - Headings
    static let heading1 = Font.system(size: 32, weight: .medium, design: .default)
    static let heading2 = Font.system(size: 24, weight: .medium, design: .default)
    static let heading3 = Font.system(size: 20, weight: .medium, design: .default)
    static let heading4 = Font.system(size: 18, weight: .medium, design: .default)
    
    // MARK: - Body
    static let bodyLarge = Font.system(size: 18, weight: .regular, design: .default)
    static let body = Font.system(size: 16, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)
    
    // MARK: - Labels
    static let label = Font.system(size: 16, weight: .medium, design: .default)
    static let labelSmall = Font.system(size: 14, weight: .medium, design: .default)
    static let labelTiny = Font.system(size: 12, weight: .medium, design: .default)
    
    // MARK: - Caption
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let captionSmall = Font.system(size: 10, weight: .regular, design: .default)
}

extension UIFont {
    // MARK: - Body
    static let body = UIFont.systemFont(ofSize: 16, weight: .regular)
    static let bodyLarge = UIFont.systemFont(ofSize: 18, weight: .regular)
    static let bodySmall = UIFont.systemFont(ofSize: 14, weight: .regular)
    
    // MARK: - Labels
    static let label = UIFont.systemFont(ofSize: 16, weight: .medium)
    static let labelSmall = UIFont.systemFont(ofSize: 14, weight: .medium)
    static let labelTiny = UIFont.systemFont(ofSize: 12, weight: .medium)
}

