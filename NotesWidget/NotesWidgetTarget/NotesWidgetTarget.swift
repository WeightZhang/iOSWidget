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
        
        let entry = SimpleEntry(date: Date(), configuration: configuration, alignment: getPosition())
        completion(entry)
    }

    public func timeline(for configuration: ConfigurationIntent, with context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of four entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 4 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, alignment: getPosition())
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    public let date: Date
    public let configuration: ConfigurationIntent
    public let alignment: Alignment
}

struct PlaceholderView : View {
    var body: some View {
        //Staticlly set image
         Image("DefaultImage")
             .resizable()
            .aspectRatio(contentMode: .fill)
    }
}

enum ePosition: String{
    case lower_left = "LL"
    case lower_right = "LR"
    case upper_left = "UL"
    case upper_right = "UR"
    case random_pos = "RP"
}

struct DataStruct {
    var storedImgData: Data!
    var storedTxtData: String!
    var storedPosData: ePosition!
}

func getData() -> DataStruct {
    var data: DataStruct = DataStruct()
    
    if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget") {
        data.storedImgData = userDefaults.data(forKey: "IMG_DATA")
        data.storedTxtData = userDefaults.string(forKey: "TEXT_DATA")
        data.storedPosData = ePosition(rawValue: userDefaults.string(forKey: "POS_DATA") ?? "LR")
    }
    
    if(data.storedImgData == nil){
        data.storedImgData = UIImage(named: "DefaultImage")?.pngData()
    }
    if(data.storedTxtData == nil){
        data.storedTxtData = ""
    }
    if(data.storedPosData == nil){
        data.storedPosData = .lower_right
    }
    
    return data
}
func getPosition(pos: ePosition) -> Alignment{
    switch pos {
    case .lower_left:
        return Alignment.bottomLeading
    case .lower_right:
        return Alignment.bottomTrailing
    case .upper_left:
        return Alignment.topLeading
    case .upper_right:
        return Alignment.topTrailing
    default:
        return Alignment.bottomTrailing
    }
}
func getPosition() -> Alignment{
    var storedPosData: ePosition = .lower_left
    if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget") {
        storedPosData = ePosition(rawValue: userDefaults.string(forKey: "POS_DATA") ?? "LR")!
    }
    
    let AlignmentArray: [Alignment] = [Alignment.bottomLeading, Alignment.bottomTrailing, Alignment.topLeading, Alignment.topTrailing]
    
    switch storedPosData {
    case .lower_left:
        return AlignmentArray[0]
    case .lower_right:
        return AlignmentArray[1]
    case .upper_left:
        return AlignmentArray[2]
    case .upper_right:
        return AlignmentArray[3]
    case .random_pos:
        return AlignmentArray[Int.random(in: 0...3)]
    default:
        return AlignmentArray[1]
    }
}

struct TextOverlay: View {
    var data = getData()
    var body: some View {
        ZStack {
            Text(data.storedTxtData)
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
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            VStack{
                Image(uiImage: UIImage.init(data: data.storedImgData)!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)

            }.background(Color.black)
            .overlay(data.storedTxtData != "" ? TextOverlay() : nil, alignment: entry.alignment)
        case .systemMedium:
            VStack{
                Image(uiImage: UIImage.init(data: data.storedImgData)!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)

            }.background(Color.black)
            .overlay(data.storedTxtData != "" ? TextOverlay() : nil, alignment: entry.alignment)
        case .systemLarge:
            VStack{
                Image(uiImage: UIImage.init(data: data.storedImgData)!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)

            }.background(Color.black)
            .overlay(data.storedTxtData != "" ? TextOverlay().padding() : nil, alignment: entry.alignment)
        default:
            VStack{
                Image(uiImage: UIImage.init(data: data.storedImgData)!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)

            }.background(Color.black)
            .overlay(data.storedTxtData != "" ? TextOverlay() : nil, alignment: entry.alignment)
        }
        
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
