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

- [x] **Workout Sessions (`HKWorkoutSession`)**: When the user starts a workout on the watch, start a live HealthKit workout session. This temporarily keeps the app active on the wrist and enables high-frequency sensor reads.
- [x] **Heart Rate & Calories**: Capture live heart rate and active energy burned during the session. 
- [x] **Correlating Effort to Vitals**: Save the average/max heart rate and total calories burned directly onto the `StrengthWorkoutLog` model in SwiftData. 
- [x] **Advanced Charts**: In the iPhone `ProgressChartView`, allow users to plot their "Average Heart Rate" over time alongside their "Total Volume" to see if their cardiovascular efficiency during strength training is improving.

## Phase 4: Modern iOS Experiences (Dynamic Island)

- [ ] **Live Activities**: When a user is resting between sets, display a Live Activity on the iPhone Lock Screen and Dynamic Island showing the countdown timer and what the next exercise is. This allows users to stay engaged without keeping the app open.

## Phase 5: Advanced Programming & Periodization

To elevate TrackFit from a simple logging app to a comprehensive training planner, the app should support structured long-term progression.

- [ ] **Periodization Framework**: Implement the ability to structure training into Macrocycles (long-term, e.g., 6-12 months), Mesocycles (phases of several weeks), and Microcycles (weekly plans).
- [ ] **Periodization Models**: Allow users or coaches to select between linear periodization or daily undulating periodization to systematically manage volume and intensity and drive physical adaptations safely.
- [ ] **Hybrid / Concurrent Training Support**: Expand tracking to accommodate "Hybrid Athletes" who balance traditional resistance training with endurance or cardiovascular conditioning. The app could analyze data to help users avoid the "interference effect" by optimizing the schedule and volume of both modalities.

## Phase 6: Dynamic Scaling & Metcon Integration

Strength training frequently overlaps with high-intensity functional training. Adding specific tools for these environments will vastly improve the app's utility.

- [ ] **Intelligent Exercise Substitutions**: Build a dynamic scaling engine that suggests alternative movements based on equipment availability (e.g., Home Gym vs. Commercial Gym) or an athlete's skill level. For example, suggesting parallel-bar dips if a user lacks the skill for ring dips.
- [ ] **Stimulus Preservation**: Ensure the app's substitution algorithm guides users to modify loads or volume in a way that preserves the originally intended physical stimulus of the workout rather than just avoiding difficulty.
- [ ] **Cardio Conversions**: Include a quick-reference conversion engine for distance and calories (e.g., automatically converting a 400m run into a 500m row or 30/24 Assault Bike calories) depending on the available machines.
- [ ] **Metcon Specific Timers**: Add dedicated timer modes for Metabolic Conditioning (Metcons), such as AMRAP (As Many Rounds As Possible), EMOM (Every Minute on the Minute), and rounds "For Time".

## Phase 7: Holistic Recovery & Readiness

Performance in strength and hybrid training relies heavily on what happens outside the gym.

- [ ] **Readiness Scoring via HealthKit**: Leverage HealthKit data (such as Sleep duration and Heart Rate Variability) to assess central nervous system fatigue. The app could use this to suggest whether a user should push hard or take an active recovery day.
- [ ] **Nutrition Tracking Integration**: Integrate TrackFit with HealthKit's nutrition tracking to correlate caloric intake and macronutrient timing with workout performance and volume, as energy intake is paramount for athletes balancing multiple fitness modalities.