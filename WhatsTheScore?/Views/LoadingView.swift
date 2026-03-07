import SwiftUI

struct LoadingView: View {
    @State private var progress: CGFloat = 0.0
    @State private var tipIndex: Int = Int.random(in: 0..<LoadingView.proTips.count)
    @State private var messageIndex: Int = Int.random(in: 0..<LoadingView.loadingMessages.count)

    private static let loadingMessages: [(title: String, subtitle: String)] = [
        ("Checking the scoreboard...", "Calculating the GOAT..."),
        ("Loading the GOAT...", "Crunching the numbers..."),
        ("Warming up...", "Stretching those stats..."),
        ("Rallying the squad...", "Getting everyone in position..."),
        ("Shuffling the deck...", "Dealing out the data..."),
        ("Rolling the dice...", "Luck is loading..."),
        ("Polishing the trophy...", "Making it extra shiny..."),
        ("Counting victories...", "There are a lot of them..."),
        ("Summoning the leaderboard...", "Almost there..."),
        ("Preparing the arena...", "May the best player win..."),
    ]

    private static let proTips: [String] = [
        "Keep your win streak alive to climb the ranks faster!",
        "You can create custom point systems for any game.",
        "Invite friends with your leaderboard's unique code.",
        "Track multiple games in a single leaderboard.",
        "Drag to reorder placements when recording a match.",
        "Your rank is based on total points across all games.",
        "Long-press a game in the list to delete it.",
        "Consistency beats lucky wins for climbing ranks.",
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Glowing trophy
            ZStack {
                Circle()
                    .fill(AppColors.flame.opacity(0.3))
                    .frame(width: 132, height: 132)
                    .blur(radius: 60)

                Circle()
                    .fill(AppColors.flame.opacity(0.10))
                    .frame(width: 128, height: 128)
                    .overlay(
                        Circle()
                            .stroke(AppColors.flame.opacity(0.20), lineWidth: 1)
                    )
                    .shadow(color: AppColors.flame.opacity(0.3), radius: 40, x: 0, y: 0)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(AppColors.flame)
            }
            .padding(.bottom, 40)

            // Text content
            VStack(spacing: 8) {
                Text(Self.loadingMessages[messageIndex].title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(Self.loadingMessages[messageIndex].subtitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.gray)
            }
            .padding(.bottom, 32)

            // Progress bar
            VStack(spacing: 10) {
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 6)
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppColors.flame)
                                .frame(width: geo.size.width * progress, height: 6)
                                .shadow(color: AppColors.flame.opacity(0.6), radius: 12, x: 0, y: 0)
                        }
                }
                .frame(height: 6)

                HStack {
                    Text("PROCESSING DATA")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.5)
                        .foregroundStyle(AppColors.flame)

                    Spacer()

                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.5)
                        .foregroundStyle(AppColors.flame)
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            // Pro Tip card
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.flame.opacity(0.20))
                        .frame(width: 36, height: 36)

                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.flame)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Pro Tip")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(AppColors.flame)

                    Text(Self.proTips[tipIndex])
                        .font(.system(size: 13))
                        .foregroundStyle(Color(white: 0.75))
                        .lineSpacing(2)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.flame.opacity(0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.flame.opacity(0.20), lineWidth: 1)
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.pageBackground.ignoresSafeArea())
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                progress = 0.85
            }
        }
    }
}
