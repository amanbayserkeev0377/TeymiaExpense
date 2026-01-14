import SwiftUI

enum IconColor: String, CaseIterable, Codable {
    case color1, color2, color3, color4, color5, color6, color7, color8, color9, color10, color11, color12, color13, color14, color15, color16, color17, color18, color19
    
    var color: Color {
        switch self {
        case .color1: return .color1
        case .color2:     return .color2
        case .color3:  return .color3
        case .color4:  return .color4
        case .color5:    return .color5
        case .color6:   return .color6
        case .color7:    return .color7
        case .color8:    return .color8
        case .color9:    return .color9
        case .color10:    return .color10
        case .color11:  return .color11
        case .color12:  return .color12
        case .color13:   return .color13
        case .color14:    return .color14
        case .color15:    return .color15
        case .color16:    return .color16
        case .color17:    return .color17
        case .color18:    return .color18
        case .color19:    return .color19
        }
    }
}
