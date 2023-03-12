import SwiftUI

public struct DonkeyUI {
    public private(set) var text = "Hello, World!"

    public init() {
    }
}



struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        IconView(image: "xmark", color: .blue)
    }
}

