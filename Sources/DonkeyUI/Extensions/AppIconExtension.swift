//
//  AppIconExtension.swift
//  BuildUp
//
//  Created by paco on 05/11/22.
//

import Foundation
import SwiftUI

public extension Bundle {
    var iconFileName: String? {
        guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let iconFileName = iconFiles.last
        else { return nil }
        return iconFileName
    }
}

public struct AppIcon: View {
    public var body: some View {
        Bundle.main.iconFileName
            .flatMap { UIImage(named: $0) }
            .map { Image(uiImage: $0) }
        
    }
}
