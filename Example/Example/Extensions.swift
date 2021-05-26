import UIKit

extension UIColor {
    
    public convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        guard let hex = Int(hexString, radix: 16), 0...0xffffff ~= hex else {
            self.init(red: 0, green: 0, blue: 0, alpha: alpha)
            return
        }
        
        self.init(red: CGFloat((hex >> 16) & 0xff) / 255.0,
                  green: CGFloat((hex >> 8) & 0xff) / 255.0,
                  blue: CGFloat(hex & 0xff) / 255.0,
                  alpha: alpha)
    }
    
    func isLight(threshold: Float = 0.5) -> Bool? {
        let originalCGColor = self.cgColor
        let rgbCgColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        
        guard let components = rgbCgColor?.components else {
            return nil
        }
        
        guard components.count >= 3 else {
            return nil
        }

        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
        return (brightness > threshold)
    }
    
}
