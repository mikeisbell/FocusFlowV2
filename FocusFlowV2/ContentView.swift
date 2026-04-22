//
//  ContentView.swift
//  FocusFlowV2
//
//  Created by Michael Isbell on 4/21/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0:  TodayView(selectedTab: $selectedTab)
                case 1:  LaterView()
                default: AddView(selectedTab: $selectedTab)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 56)
            }

            CustomTabBar(selectedTab: $selectedTab)
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(icon: "circle.fill", label: "Now", isSelected: selectedTab == 0) {
                selectedTab = 0
            }

            Button {
                selectedTab = 2
            } label: {
                ZStack {
                    Circle()
                        .fill(AppColors.accentGradient)
                        .frame(width: 56, height: 56)
                        .shadow(color: AppColors.accent.opacity(0.35), radius: 12, x: 0, y: 4)
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .offset(y: -16)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)

            TabBarButton(icon: "list.bullet", label: "Later", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
        }
        .frame(height: 56)
        .padding(.horizontal, 16)
        .background(AppColors.cardBackground, ignoresSafeAreaEdges: .bottom)
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: -3)
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundStyle(isSelected ? AppColors.accent : Color.secondary)
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
