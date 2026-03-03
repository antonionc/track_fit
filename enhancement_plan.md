# TrackFit: Future Enhancements Plan

To take TrackFit to the next level, integrating deeply with the Apple ecosystem—specifically HealthKit and watchOS—will provide a much richer experience. Here is a proposed roadmap focusing on fitness tracking and vitals.

## Phase 1: HealthKit Integration (iOS)

Before building a watch app, the iOS app needs to be able to read and write to Apple Health.

- [x] **Write Workouts to Health**: When a user finishes a strength training session in TrackFit, save an `HKWorkout` of type `TraditionalStrengthTraining` to HealthKit, contributing to their Activity Rings.
- [x] **Read Vitals (Contextual)**: Read the user's body mass (weight) from HealthKit to calculate advanced metrics like "Strength-to-Weight Ratio" for exercises like squats or deadlifts.
- [x] Add `ProfileView` and `Strength-to-Weight Ratio` metrics.
- [x] Customize application icon.

## Phase 2: Apple Watch Companion App (watchOS)

A dedicated Apple Watch app is the best way to track workouts seamlessly without needing to carry a phone around the gym.

- [x] Add the `track_fit Watch App` target to the Xcode project.
- [x] Create `WatchSessionManager` on iOS and WatchOS for `WatchConnectivity`.
- [x] **Independent Logging**: Build a watchOS UI using SwiftUI that lets users view their routine and log sets directly from their wrist. (Implemented `WatchContentView` and `WatchWorkoutActiveView`).
- [x] **Data Synchronization**: Update iOS `WorkoutLoggingView` to receive and save synced sets.
- [x] **Rest Timers with Haptics**: After logging a set, automatically start a rest timer. When the timer finishes, trigger a distinct haptic notification on the wrist to prompt the next set. (Implemented `RestTimerView`).
- [x] Verify Simulator pairing, connectivity messages, and haptics functionally.

## Phase 3: Live Vitals Tracking (watchOS + HealthKit)

This is where the Apple Watch integration becomes truly powerful by merging strength data with cardiovascular data.

- [ ] **Workout Sessions (`HKWorkoutSession`)**: When the user starts a workout on the watch, start a live HealthKit workout session. This temporarily keeps the app active on the wrist and enables high-frequency sensor reads.
- [ ] **Heart Rate & Calories**: Capture live heart rate and active energy burned during the session. 
- [ ] **Correlating Effort to Vitals**: Save the average/max heart rate and total calories burned directly onto the `StrengthWorkoutLog` model in SwiftData. 
- [ ] **Advanced Charts**: In the iPhone `ProgressChartView`, allow users to plot their "Average Heart Rate" over time alongside their "Total Volume" to see if their cardiovascular efficiency during strength training is improving.

## Phase 4: Modern iOS Experiences (Dynamic Island)

- [ ] **Live Activities**: When a user is resting between sets, display a Live Activity on the iPhone Lock Screen and Dynamic Island showing the countdown timer and what the next exercise is. This allows users to stay engaged without keeping the app open.
