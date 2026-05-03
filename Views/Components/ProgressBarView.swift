import SwiftUI

struct ProgressBarView: View {
    let progress: Double
    let fillColor: Color
    let height: CGFloat
    var trackColor: Color = Color(.systemGray5)

    @State private var animatedProgress: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(trackColor)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(fillColor)
                    .frame(width: geometry.size.width * animatedProgress)
            }
        }
        .frame(height: height)
        .onAppear {
            animatedProgress = 0
            withAnimation(.easeOut(duration: 0.6)) {
                animatedProgress = max(0, min(progress, 1))
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeOut(duration: 0.6)) {
                animatedProgress = max(0, min(newValue, 1))
            }
        }
    }
}
