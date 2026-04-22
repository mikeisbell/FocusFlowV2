import SwiftUI

struct AppColors {
    static let background = Color("AppBackground")
    static let cardBackground = Color("CardBackground")
    static let accent = Color("Accent")
    static let accentEnd = Color("AccentEnd")
    static let mutedText = Color("MutedText")
    static let doneGreen = Color("DoneGreen")

    static let accentGradient = LinearGradient(
        colors: [accent, accentEnd],
        startPoint: .leading,
        endPoint: .trailing
    )
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                AppColors.accentGradient
                    .opacity(configuration.isPressed ? 0.85 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

struct OutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(AppColors.accent)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(AppColors.accent, lineWidth: 1.5)
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}
