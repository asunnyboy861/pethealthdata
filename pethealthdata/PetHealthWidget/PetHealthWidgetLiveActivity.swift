//
//  PetHealthWidgetLiveActivity.swift
//  PetHealthWidget
//
//  Created by MacMini4 on 2026/3/9.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PetHealthWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PetHealthWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PetHealthWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PetHealthWidgetAttributes {
    fileprivate static var preview: PetHealthWidgetAttributes {
        PetHealthWidgetAttributes(name: "World")
    }
}

extension PetHealthWidgetAttributes.ContentState {
    fileprivate static var smiley: PetHealthWidgetAttributes.ContentState {
        PetHealthWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PetHealthWidgetAttributes.ContentState {
         PetHealthWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PetHealthWidgetAttributes.preview) {
   PetHealthWidgetLiveActivity()
} contentStates: {
    PetHealthWidgetAttributes.ContentState.smiley
    PetHealthWidgetAttributes.ContentState.starEyes
}
