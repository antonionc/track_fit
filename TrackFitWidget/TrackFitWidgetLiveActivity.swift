//
//  TrackFitWidgetLiveActivity.swift
//  TrackFitWidget
//
//  Created by Antonio Navarro Cano on 3/3/26.
//

import ActivityKit
import WidgetKit
import SwiftUI



struct TrackFitWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RestTimerAttributes.self) { context in
            // Lock screen/banner UI goes here
            HStack {
                VStack(alignment: .leading) {
                    Text("Resting: \(context.attributes.exerciseName)")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Up next: Set \(context.state.nextSetNumber)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(timerInterval: Date()...context.state.endDate, countsDown: true)
                    .font(.system(.title, design: .monospaced).weight(.bold))
                    .foregroundColor(.cyan)
                    .multilineTextAlignment(.trailing)
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.8))
            .activitySystemActionForegroundColor(Color.cyan)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here. Compose the expanded UI through various regions.
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                        Text("Rest")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("Set \(context.state.nextSetNumber)")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: Date()...context.state.endDate, countsDown: true)
                        .font(.title2.monospacedDigit())
                        .foregroundColor(.cyan)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.attributes.exerciseName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundColor(.cyan)
            } compactTrailing: {
                Text(timerInterval: Date()...context.state.endDate, countsDown: true)
                    .monospacedDigit()
                    .frame(width: 40)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundColor(.cyan)
            }
            .widgetURL(URL(string: "trackfit://"))
            .keylineTint(Color.cyan)
        }
    }
}

extension RestTimerAttributes {
    fileprivate static var preview: RestTimerAttributes {
        RestTimerAttributes(exerciseName: "Squat")
    }
}

extension RestTimerAttributes.ContentState {
    fileprivate static var previewState: RestTimerAttributes.ContentState {
        RestTimerAttributes.ContentState(endDate: Date().addingTimeInterval(60), nextSetNumber: 2)
     }
}

#Preview("Notification", as: .content, using: RestTimerAttributes.preview) {
   TrackFitWidgetLiveActivity()
} contentStates: {
    RestTimerAttributes.ContentState.previewState
}
