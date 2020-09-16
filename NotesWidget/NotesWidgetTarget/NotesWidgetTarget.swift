//
//  NotesWidgetTarget.swift
//  NotesWidgetTarget
//
//  Created by Andrew Rotert on 7/3/20.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let position = getRandomPos()
        let widgetData: DataStruct = getData(loadPos: position)
        return SimpleEntry(date: Date(), image: UIImage.init(data: widgetData.storedImgData)!, text: widgetData.storedTxtData, alignment: getPosition(loadPos: position))
        
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let position = getRandomPos()
        let widgetData: DataStruct = getData(loadPos: position)
        let entry = SimpleEntry(date: Date(),
                                image: UIImage.init(data: widgetData.storedImgData)!,
                                text: widgetData.storedTxtData,
                                alignment: getPosition(loadPos: position))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of six entries 10min apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 6 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset*10, to: currentDate)!
            let position = getRandomPos()
            let widgetData: DataStruct = getData(loadPos: position)
            
            let entry = SimpleEntry(date: entryDate,
                                    image: UIImage.init(data: widgetData.storedImgData)!,
                                    text: widgetData.storedTxtData,
                                    alignment: getPosition(loadPos: position))
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    public let date: Date
    public let image: UIImage
    public let text: String
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

func getData(loadPos: Int) -> DataStruct {
    var data: DataStruct = DataStruct()
    
    if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget") {
        data.storedImgData = userDefaults.data(forKey: "IMG_DATA\(loadPos)")
        data.storedTxtData = userDefaults.string(forKey: "TEXT_DATA\(loadPos)")
        data.storedPosData = ePosition(rawValue: userDefaults.string(forKey: "POS_DATA\(loadPos)") ?? "LR")
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
func getPosition(loadPos: Int) -> Alignment{
    var storedPosData: ePosition = .lower_left
    if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget") {
        storedPosData = ePosition(rawValue: userDefaults.string(forKey: "POS_DATA\(loadPos)") ?? "LR")!
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
    }
}

func countSavedData() -> Int{
    var foundImgData: Int = 0
    var storedImgData: Data!
    repeat {
        if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget") {
            storedImgData = userDefaults.data(forKey: "IMG_DATA\(foundImgData)")
            if(storedImgData != nil){
                foundImgData += 1
            }
        }
    } while(storedImgData != nil)
    
    return foundImgData
}
func getRandomPos() -> Int{
    return Int.random(in: 0...(countSavedData()-1))
}

struct TextOverlay: View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            Text(verbatim: entry.text)
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
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            VStack{
                Image(uiImage: entry.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)

            }.background(Color.black)
            .overlay(entry.text != "" ? TextOverlay(entry: entry) : nil, alignment: entry.alignment)
        case .systemMedium:
            VStack{
                Image(uiImage: entry.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)

            }.background(Color.black)
            //.overlay(data.storedTxtData != "" ? TextOverlay() : nil, alignment: entry.alignment)
            .overlay(entry.text != "" ? TextOverlay(entry: entry).padding(Edge.Set.top, CGFloat(100)) : nil, alignment: Alignment.center)
        case .systemLarge:
            VStack{
                Image(uiImage: entry.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)

            }.background(Color.black)
            .overlay(entry.text != "" ? TextOverlay(entry: entry).padding() : nil, alignment: entry.alignment)
        default:
            VStack{
                Image(uiImage: entry.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)

            }.background(Color.black)
            .overlay(entry.text != "" ? TextOverlay(entry: entry) : nil, alignment: entry.alignment)
        }
        
    }
}

@main
struct NotesWidgetTarget: Widget {
    private let kind: String = "NotesWidgetTarget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NotesWidgetTargetEntryView(entry: entry)
        }
        .configurationDisplayName("Picture Box")
        .description("View a picture on your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct NotesWidgetTarget_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderView()
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        PlaceholderView()
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        PlaceholderView()
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
/*
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
         
         let position = getRandomPos()
         let widgetData: DataStruct = getData(loadPos: position)
                 
         let entry = SimpleEntry(date: Date(),
                                 configuration: configuration,
                                 image: UIImage.init(data: widgetData.storedImgData)!,
                                 text: widgetData.storedTxtData,
                                 alignment: getPosition(loadPos: position))
         completion(entry)
     }

     public func timeline(for configuration: ConfigurationIntent, with context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
         var entries: [SimpleEntry] = []

         // Generate a timeline consisting of six entries 10min apart, starting from the current date.
         let currentDate = Date()
         for hourOffset in 0 ..< 6 {
             let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset*10, to: currentDate)!
             let position = getRandomPos()
             let widgetData: DataStruct = getData(loadPos: position)
             
             let entry = SimpleEntry(date: entryDate,
                                     configuration: configuration,
                                     image: UIImage.init(data: widgetData.storedImgData)!,
                                     text: widgetData.storedTxtData,
                                     alignment: getPosition(loadPos: position))
             entries.append(entry)
         }

         let timeline = Timeline(entries: entries, policy: .atEnd)
         completion(timeline)
     }
 }

 struct SimpleEntry: TimelineEntry {
     public let date: Date
     public let configuration: ConfigurationIntent
     public let image: UIImage
     public let text: String
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

 func getData(loadPos: Int) -> DataStruct {
     var data: DataStruct = DataStruct()
     
     if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget") {
         data.storedImgData = userDefaults.data(forKey: "IMG_DATA\(loadPos)")
         data.storedTxtData = userDefaults.string(forKey: "TEXT_DATA\(loadPos)")
         data.storedPosData = ePosition(rawValue: userDefaults.string(forKey: "POS_DATA\(loadPos)") ?? "LR")
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
 func getPosition(loadPos: Int) -> Alignment{
     var storedPosData: ePosition = .lower_left
     if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget") {
         storedPosData = ePosition(rawValue: userDefaults.string(forKey: "POS_DATA\(loadPos)") ?? "LR")!
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
     }
 }

 func countSavedData() -> Int{
     var foundImgData: Int = 0
     var storedImgData: Data!
     repeat {
         if let userDefaults = UserDefaults(suiteName: "group.com.putterfitter.NotesWidget") {
             storedImgData = userDefaults.data(forKey: "IMG_DATA\(foundImgData)")
             if(storedImgData != nil){
                 foundImgData += 1
             }
         }
     } while(storedImgData != nil)
     
     return foundImgData
 }
 func getRandomPos() -> Int{
     return Int.random(in: 0...(countSavedData()-1))
 }

 struct TextOverlay: View {
     var entry: Provider.Entry
     
     var body: some View {
         ZStack {
             Text(entry.text)
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
     @Environment(\.widgetFamily) var family
     
     @ViewBuilder
     var body: some View {
         switch family {
         case .systemSmall:
             VStack{
                 Image(uiImage: entry.image)
                     .resizable()
                     .aspectRatio(contentMode: .fill)

             }.background(Color.black)
             .overlay(entry.text != "" ? TextOverlay(entry: entry) : nil, alignment: entry.alignment)
         case .systemMedium:
             VStack{
                 Image(uiImage: entry.image)
                     .resizable()
                     .aspectRatio(contentMode: .fill)

             }.background(Color.black)
             //.overlay(data.storedTxtData != "" ? TextOverlay() : nil, alignment: entry.alignment)
             .overlay(entry.text != "" ? TextOverlay(entry: entry).padding(Edge.Set.top, CGFloat(100)) : nil, alignment: Alignment.center)
         case .systemLarge:
             VStack{
                 Image(uiImage: entry.image)
                     .resizable()
                     .aspectRatio(contentMode: .fill)

             }.background(Color.black)
             .overlay(entry.text != "" ? TextOverlay(entry: entry).padding() : nil, alignment: entry.alignment)
         default:
             VStack{
                 Image(uiImage: entry.image)
                     .resizable()
                     .aspectRatio(contentMode: .fill)

             }.background(Color.black)
             .overlay(entry.text != "" ? TextOverlay(entry: entry) : nil, alignment: entry.alignment)
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
             placeholder: PlaceholderView() ){ entry in
             NotesWidgetTargetEntryView(entry: entry)
         }
         .configurationDisplayName("Picture Box")
         .description("View a picture on your home screen.")
         .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
     }
 }

 struct NotesWidgetTarget_Previews: PreviewProvider {
     static var previews: some View {
         PlaceholderView()
             .previewContext(WidgetPreviewContext(family: .systemSmall))
         PlaceholderView()
             .previewContext(WidgetPreviewContext(family: .systemMedium))
         PlaceholderView()
             .previewContext(WidgetPreviewContext(family: .systemLarge))
     }
 }

 */
