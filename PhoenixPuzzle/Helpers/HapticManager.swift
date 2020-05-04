//
//  HapticManager.swift

import UIKit

public enum HapticFeedback: CaseIterable {
    case error
    case success
    case warning
    case lightImpact
    case mediumImpact
    case heavyImpact
    case selectionChanged
    case none
}

// MARK: - Public Functions
public extension HapticFeedback {
    func prepare() {
        HapticFeedback.prepare(self)
    }
    
    static func prepare(_ feedback: HapticFeedback) {
        switch feedback {
        case .error, .success, .warning: notificationGenerator.prepare()
        case .lightImpact: lightImpactGenerator.prepare()
        case .mediumImpact: mediumImpactGenerator.prepare()
        case .heavyImpact: heavyImpactGenerator.prepare()
        case .selectionChanged: selectionGenerator.prepare()
        case .none: return
        }
    }
    
    func trigger() {
        HapticFeedback.trigger(self)
    }
    
    static func trigger(_ feedback: HapticFeedback) {
        switch feedback {
        case .error: triggerNotification(.error)
        case .success: triggerNotification(.success)
        case .warning: triggerNotification(.warning)
        case .lightImpact: lightImpactGenerator.impactOccurred()
        case .mediumImpact: mediumImpactGenerator.impactOccurred()
        case .heavyImpact: heavyImpactGenerator.impactOccurred()
        case .selectionChanged: selectionGenerator.selectionChanged()
        case .none: return
        }
    }
}

// MARK: - Private Trigger Functions
private extension HapticFeedback {
    static func triggerNotification(_ notification: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.notificationOccurred(notification)
    }
}

// MARK: - Private Generators
private extension HapticFeedback {
    private static var notificationGenerator = UINotificationFeedbackGenerator()
    private static var lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
    private static var mediumImpactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private static var heavyImpactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private static var selectionGenerator = UISelectionFeedbackGenerator()
}

