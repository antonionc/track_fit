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
        ActivityConfiguration(for: WorkoutPlanAttributes.self) { context in
            // Lock screen/banner UI goes here
            HStack {
                VStack(alignment: .leading) {
                    Text(context.attributes.planName)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("\(context.state.currentExerciseName) - Set \(context.state.currentSet) of \(context.state.totalSets)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                if context.state.isResting, let restEndDate = context.state.restEndDate {
                    Text(timerInterval: Date()...restEndDate, countsDown: true)
                        .font(.system(.title, design: .monospaced).weight(.bold))
                        .foregroundColor(.cyan)
                        .multilineTextAlignment(.trailing)
                } else {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.title)
                        .foregroundColor(.cyan)
                }
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.8))
            .activitySystemActionForegroundColor(Color.cyan)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here. Compose the expanded UI through various regions.
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                        Text(context.attributes.planName)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("Set \(context.state.currentSet)/\(context.state.totalSets)")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isResting, let restEndDate = context.state.restEndDate {
                        Text(timerInterval: Date()...restEndDate, countsDown: true)
                            .font(.title2.monospacedDigit())
                            .foregroundColor(.cyan)
                    } else {
                         Image(systemName: "figure.strengthtraining.traditional")
                             .foregroundColor(.cyan)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.currentExerciseName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            } compactLeading: {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundColor(.cyan)
            } compactTrailing: {
                if context.state.isResting, let restEndDate = context.state.restEndDate {
                    Text(timerInterval: Date()...restEndDate, countsDown: true)
                        .monospacedDigit()
                        .frame(width: 40)
                        .foregroundColor(.cyan)
                } else {
                    Text("\(context.state.currentSet)/\(context.state.totalSets)")
                         .font(.caption2)
                         .foregroundColor(.cyan)
                }
            } minimal: {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundColor(.cyan)
            }
            .widgetURL(URL(string: "trackfit://"))
            .keylineTint(Color.cyan)
        }
    }
}

extension WorkoutPlanAttributes {
    fileprivate static var preview: WorkoutPlanAttributes {
        WorkoutPlanAttributes(planName: "Push Day Workout")
    }
}

extension WorkoutPlanAttributes.ContentState {
    fileprivate static var previewState: WorkoutPlanAttributes.ContentState {
        WorkoutPlanAttributes.ContentState(currentExerciseName: "Bench Press", currentSet: 2, totalSets: 4, isResting: true, restEndDate: Date().addingTimeInterval(60))
     }
}

#Preview("Notification", as: .content, using: WorkoutPlanAttributes.preview) {
   TrackFitWidgetLiveActivity()
} contentStates: {
    WorkoutPlanAttributes.ContentState.previewState
}
