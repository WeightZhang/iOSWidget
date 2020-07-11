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
        //Staticlly set image
         Image("DefaultImage")
             .resizable()
             .aspectRatio(contentMode: .fit)
    }
}

struct DataStruct {
    var storedImgData: Data!
}

func getData() -> DataStruct {
    var data: DataStruct = DataStruct()
    
    if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget") {
        data.storedImgData = userDefaults.data(forKey: "IMG_DATA")
    }
    
    if(data.storedImgData == nil){
        data.storedImgData = UIImage(named: "DefaultImage")?.pngData()
    }
    
    return data
}

struct TextOverlay: View {
    var body: some View {
        ZStack {
            Text("TESTING")
                .font(.callout)
                .padding(6)
                .foregroundColor(.white)
        }.background(Color.black)
        .opacity(0.8)
        .cornerRadius(10.0)
        .padding(6)
    }
}

struct NotesWidgetTargetEntryView : View {
    var entry: Provider.Entry
    
    var data = getData()
        
    var body: some View {
        VStack{
            Image(uiImage: UIImage.init(data: data.storedImgData)!)
                .resizable()
                .aspectRatio(contentMode: .fill)

        }.background(Color.black)
        .overlay(TextOverlay(), alignment: .bottomTrailing)
    }
}

@main
struct NotesWidgetTarget: Widget {
    private let kind: String = "NotesWidgetTarget"
    
    public var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: Provider(),
            placeholder: PlaceholderView()) { entry in
            NotesWidgetTargetEntryView(entry: entry)
        }
        .configurationDisplayName("Picture Box")
        .description("View a picture on your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
