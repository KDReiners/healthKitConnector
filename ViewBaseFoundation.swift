//
//  ViewBaseFoundatio.swift
//  healthKitShaman
//
//  Created by Klaus-Dieter Reiners on 05.08.21.
//

import Foundation
import SwiftUI
import Combine

// generell parameters for layout
let labelWidth: CGFloat = 150
let textWidth: CGFloat = 150
let TextFieldWidth: CGFloat = 250
let isEditing: Bool = false

extension View {
    public func setFrame(text: Text?, alignement: Alignment, font: Font, foreGroundColor: Color) -> some View {
        let result = text.frame(width: textWidth, alignment: alignement).lineLimit(1)
        return result
    }
}
public func stuffText(pattern: String = "HKQuantityTypeIdentifier", text: String) -> String {
    var result = text
    if let range = text.range(of: pattern) {
        result = text.replacingCharacters(in: range, with: "")
    }
    return result
}
struct Tree<Value: Hashable> {
    let value: Value
    var children: [Tree]? = nil
}
