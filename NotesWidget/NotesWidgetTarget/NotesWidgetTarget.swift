//
//  NotesWidgetTarget.swift
//  NotesWidgetTarget
//
//  Created by Andrew Rotert on 7/3/20.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    public func snapshot(for configuration: ConfigurationIntent, with context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    public func timeline(for configuration: ConfigurationIntent, with context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    public let date: Date
    public let configuration: ConfigurationIntent
}

struct PlaceholderView : View {
    var body: some View {
        Text("Placeholder View")
    }
}

struct Data {
    var storedValue1: String = ""
    var storedValue2: String = ""
    var storedValue3: String = ""
    var storedValue4: String = ""
    var storedValue5: String = ""
    var backgroundIndex: Int = 0
}

func getData() -> Data {
    var data: Data = Data()
    
    if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget") {
        data.storedValue1 = userDefaults.string(forKey: "TEXT1") ?? ""
        data.storedValue2 = userDefaults.string(forKey: "TEXT2") ?? ""
        data.storedValue3 = userDefaults.string(forKey: "TEXT3") ?? ""
        data.storedValue4 = userDefaults.string(forKey: "TEXT4") ?? ""
        data.storedValue5 = userDefaults.string(forKey: "TEXT5") ?? ""
        data.backgroundIndex = userDefaults.integer(forKey: "BACKGROUND")
    }
    print(data)
    return data
}

struct NotesWidgetTargetEntryView : View {
    var entry: Provider.Entry
    
    var data = getData()

    let SelectedColor: [Color] = [Color.black, Color.white, Color.red, Color.orange, Color.yellow, Color.green, Color.blue]
    
    var body: some View {
        VStack{
            //data.storedValue1 == "" ? nil : Text(data.storedValue1)
            //data.storedValue2 == "" ? nil : Text(data.storedValue2)
            //data.storedValue3 == "" ? nil : Text(data.storedValue3)
            //data.storedValue4 == "" ? nil : Text(data.storedValue4)
            //data.storedValue5 == "" ? nil : Text(data.storedValue5)
            Image("Piper")
                .resizable()
                .aspectRatio(contentMode: .fit)

        }.background(SelectedColor[data.backgroundIndex])
    }
}

@main
struct NotesWidgetTarget: Widget {
    private let kind: String = "NotesWidgetTarget"

    public var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider(), placeholder: PlaceholderView()) { entry in
            NotesWidgetTargetEntryView(entry: entry)
        }
        .configurationDisplayName("Note Pad")
        .description("View up to five lines of custom text.")
    }
}
