//
//  TrackFitWidgetBundle.swift
//  TrackFitWidget
//
//  Created by Antonio Navarro Cano on 3/3/26.
//

import WidgetKit
import SwiftUI

@main
struct TrackFitWidgetBundle: WidgetBundle {
    var body: some Widget {
        TrackFitWidget()
        TrackFitWidgetControl()
        TrackFitWidgetLiveActivity()
    }
}
