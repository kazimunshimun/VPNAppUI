//
//  ContentView.swift
//  ZoomVPN
//
//  Created by Anik on 22/10/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

struct HomeView: View {
    @State var showSideMenu = false
    @StateObject var speedSimulator = SpeedSimultor()
    var body: some View {
        ZStack {
            Color.appPrimary
                .ignoresSafeArea()
            
            VStack {
                // top menu view
                TopMenuView(showSideMenu: $showSideMenu)
                // speed text view
                SpeedTextView(speedSimulator: speedSimulator)
                
                Spacer()
                // Progress view
                ProgressView(speedSimulator: speedSimulator)

                Spacer()
                // start stop button view
                Button(action: {
                    // start speed simulation
                    speedSimulator.startSpeedTest()
                }, label: {
                    StartStopButtonView(speedSimulator: speedSimulator)
                })
                
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.horizontal)
            
            VStack {
                Spacer()
                // drop down view
                DropdownView()
                    .padding(.horizontal, 30)
            }
            
            if showSideMenu {
                SideMenuView(showSideMenu: $showSideMenu)
                    .foregroundColor(.white)
            }
            
        }
    }
}

struct TopMenuView: View {
    @Binding var showSideMenu: Bool
    var body: some View {
        HStack {
            Button(action: {
                //show side menu
                showSideMenu = true
            }, label: {
                VStack {
                    HStack {
                        Circle()
                            .frame(width: 6, height: 6)
                        Circle()
                            .frame(width: 6, height: 6)
                    }
                    
                    HStack {
                        Circle()
                            .frame(width: 6, height: 6)
                        Circle()
                            .frame(width: 6, height: 6)
                    }
                }
                .padding()
            })
            
            Text("ZOOM")
                .font(.system(size: 18, weight: .black))
            
            Text("VPN")
                .font(.system(size: 18, weight: .regular))
            
            Spacer()
            
            PremiumView()
        }
        
    }
}

struct PremiumView: View {
    var fillRect = true
    var body: some View {
        ZStack {
            if fillRect {
                RoundedRectangle(cornerRadius: 20.0)
                    .fill(Color.darkPurple)
                    .frame(width: 135, height: 40)
            } else {
                RoundedRectangle(cornerRadius: 20.0)
                    .stroke(Color.darkPurple)
                    .frame(width: 135, height: 40)
            }
            
            HStack {
                Image(systemName: "flame.fill")
                Text("GO PREMIUM")
                    .font(.system(size: 12, weight: .regular))
            }
        }
    }
}

struct SpeedTextView: View {
    @ObservedObject var speedSimulator: SpeedSimultor
    var body: some View {
        ZStack {
            EmitterView(width: UIScreen.screenWidth, height: 80)
                .opacity(speedSimulator.start ? 1.0 : 0.0)
                .frame(height: 80)
            VStack {
                Text(String(format: "%.2f", speedSimulator.calculatedSpeed))
                    .font(.system(size: 40, weight: .semibold))
                    .animation(.none)
                
                Text("mb/s")
                    .font(.system(size: 16, weight: .light))
            }
        }
    }
}

struct EmitterView: UIViewRepresentable {
    let width: CGFloat
    let height: CGFloat
    
    func makeUIView(context: Context) -> some UIView {
        let size = CGSize(width: width, height: height)
        let host = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let emitterLayer = CAEmitterLayer()
        emitterLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        host.layer.addSublayer(emitterLayer)
        host.layer.masksToBounds = true
        
        emitterLayer.emitterShape = .circle
        emitterLayer.emitterPosition = CGPoint(x: size.width/2, y: size.height/2)
        emitterLayer.emitterSize = size
        
        let emitterCell = EmitterCell().content(.circle(20))
        emitterCell.color = UIColor.white.cgColor
        emitterCell.birthRate = 25
        emitterCell.lifetime = 4.0
        emitterCell.scale = 0.01
        emitterCell.alphaRange = 0.1
        emitterCell.alphaSpeed = 0.3
        
        emitterLayer.emitterCells = [emitterCell]
        
        return host
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

fileprivate extension EmitterCell.Content {
    var image: UIImage {
        switch self {
        case let .image(image):
            return image
        case let .circle(radius):
            let size = CGSize(width: radius * 2, height: radius * 2)
            return UIGraphicsImageRenderer(size: size).image { context in
                context.cgContext.setFillColor(UIColor.white.cgColor)
                context.cgContext.addPath(CGPath(ellipseIn: CGRect(origin: .zero, size: size), transform: nil))
                context.cgContext.fillPath()
            }
        }
    }
}

class EmitterCell: CAEmitterCell {
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public enum Content {
        case image(UIImage)
        case circle(CGFloat)
    }
    
    dynamic func content(_ content: Content) -> Self {
        self.contents = content.image.cgImage
        return self
    }
}

struct ProgressView: View {
    @ObservedObject var speedSimulator: SpeedSimultor
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.progressBackgroundLinear, lineWidth: 24)
                .frame(width: 250, height: 250)
            
            Circle()
                .frame(width: 200, height: 200)
            
            ForEach(Array(stride(from: 0, through: 10, by: 1)), id: \.self) { i in
                Text("\(i * 10)")
                    .rotationEffect(.degrees(-120 - Double(i * 30)))
                    .offset(x: 160)
                    .rotationEffect(.degrees(Double(i * 30)))
            }
            .rotationEffect(.degrees(120))
            
            Circle()
                .trim(from: 0.1, to: speedSimulator.progress)
                .stroke(Color.progressLinear, style: StrokeStyle(lineWidth: 24, lineCap: .round))
                .frame(width: 250, height: 250)
                .rotationEffect(.degrees(90))
        }
    }
}

struct StartStopButtonView: View {
    @ObservedObject var speedSimulator: SpeedSimultor
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(speedSimulator.start ? Color.stopColor : Color.darkPurple)
                .frame(width: 110, height: 50)
            
            HStack {
                Image(systemName: "power")
                    .font(.system(size: 18, weight: .black))
                Text(speedSimulator.start ? "Stop" : "Start")
                    .font(.system(size: 18, weight: .regular))
            }
        }
    }
}

struct DropdownView: View {
    @StateObject var dropdownManager = DropdownManager()
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.dropDown)
                .frame(height: dropdownManager.expanded ? 300 : 60)
            HStack(alignment: .top) {
                // drop down items
                if !dropdownManager.expanded {
                    RegionItemView(region: dropdownManager.regions[dropdownManager.selectedIndex])
                        .onTapGesture {
                            withAnimation { dropdownManager.expandCollapseView() }
                        }
                } else {
                    VStack(spacing: 0) {
                        ForEach(dropdownManager.regions) { region in
                            RegionItemView(region: region)
                                .onTapGesture {
                                    withAnimation { dropdownManager.selectItem(region: region) }
                                }
                        }
                    }
                }
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .rotationEffect(dropdownManager.expanded ? .degrees(180) : .zero)
                    .padding()
                    .padding(.top, 10)
                    .onTapGesture {
                        withAnimation { dropdownManager.expandCollapseView() }
                    }
            }
            
        }
    }
}

struct RegionItemView: View {
    let region: Region
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white.opacity(0.001)) // so that whole item tapable
                .frame(height: 60)
            
            HStack(spacing: 16) {
                Text(region.imageName)
                    .font(.system(size: 55))
                    .fixedSize()
                    .frame(width: 30, height: 30)
                    .cornerRadius(15)
                
                Text(region.name)
                    .bold()
                    .foregroundColor(.white)
                
                Spacer()
                
                ZStack(alignment: .leading) {
                    HStack(spacing: 2) {
                        ForEach(Array(stride(from: 0, to: 5, by: 1)), id: \.self) { _ in
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: 6, height: 6)
                        }
                    }
                    
                    HStack(spacing: 2) {
                        ForEach(Array(stride(from: 0, to: region.strength, by: 1)), id: \.self) { _ in
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct SideMenuView: View {
    @State var startAnimation = false
    @Binding var showSideMenu: Bool
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .ignoresSafeArea() // so other element behind side meue is not tappable
            // two rotated rectangle
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.sideBackground)
                .rotationEffect(startAnimation ? .degrees(15) : .zero, anchor: .bottomTrailing)
                .offset(x: startAnimation ? -UIScreen.screenWidth/2 : -UIScreen.screenWidth, y: 20)
                .scaleEffect(0.85)
            
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.sideBackground)
                .rotationEffect(startAnimation ? .degrees(10) : .zero, anchor: .bottomTrailing)
                .offset(x: startAnimation ? -UIScreen.screenWidth/2 : -UIScreen.screenWidth, y: 20)
                .scaleEffect(0.95)
                .shadow(color: .black, radius: 50)
            
            VStack(alignment: .leading) {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            startAnimation.toggle()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.showSideMenu = false
                            }
                        }
                    }, label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .padding()
                    })
                }
                .offset(x: -UIScreen.screenWidth/4)
                // user view
                UserView()
                
                Spacer()
                
                // menus list
                MenuListView()
                
                Spacer()
                
                // go premium view
                PremiumView(fillRect: false)
                
                Spacer(minLength: 180)
            }
            .padding(.horizontal)
            .offset(x: startAnimation ? 0.0 : -UIScreen.screenWidth)
            .animation(.easeIn(duration: 0.3))
        }
        .onAppear {
            withAnimation { startAnimation.toggle() }
        }
    }
}

struct UserView: View {
    var body: some View {
        VStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 70, height: 70)
            
            Text("Hello,")
            Text("Kavin Breadly")
                .bold()
        }
    }
}

struct MenuListView: View {
    var body: some View {
        ForEach(Data.menus) { menu in
            MenuItemView(menu: menu)
                .padding(.vertical, 8)
        }
    }
}

struct MenuItemView: View {
    let menu: MenuItem
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: menu.imageName)
                .fixedSize(horizontal: true, vertical: true)
                .frame(width: 20)
            Text(menu.name)
                .font(.system(size: 14, weight: .bold))
        }
    }
}

struct MenuItem: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
}

struct Region: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let strength: Int
}

class DropdownManager: ObservableObject {
    @Published var regions = Data.regions
    @Published var expanded = false
    var selectedIndex = 0
    
    func expandCollapseView() {
        expanded.toggle()
    }
    
    func selectItem(region: Region) {
        if let index = regions.firstIndex(where: { $0.id == region.id }) {
            expandCollapseView()
            selectedIndex = index
        }
    }
    
}

class SpeedSimultor: ObservableObject {
    @Published var progress: CGFloat = 0.0
    @Published var start = false
    
    let expectedRange = 35...40
    var calculatedSpeed: CGFloat = 0.0
    
    func startSpeedTest() {
        start.toggle()
        
        for i in Array(stride(from: 0, through: 60, by: 0.2)) {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                if self.start {
                    self.calculateRandomSpeed()
                    self.calculateProgress()
                }
            }
        }
    }
    
    func calculateRandomSpeed() {
        let speed = Float(arc4random() % 8)
        
        if expectedRange.contains(Int(calculatedSpeed)) {
            if speed > 4 {
                calculatedSpeed += CGFloat(speed/5)
            } else {
                calculatedSpeed -= CGFloat(speed/5)
            }
        } else if calculatedSpeed > 40 {
            calculatedSpeed -= CGFloat(speed/6)
        } else {
            calculatedSpeed += CGFloat(speed/2)
        }
    }
    
    func calculateProgress() {
        withAnimation(.linear(duration: 0.2)) {
            progress = calculatedSpeed/125 + 0.1
        }
    }
}

struct Data {
    static let regions = [
        Region(name: "Singapore", imageName: "🇸🇬", strength: 4),
        Region(name: "USA", imageName: "🇺🇸", strength: 3),
        Region(name: "Australia", imageName: "🇦🇺", strength: 3),
        Region(name: "Canada", imageName: "🇨🇦", strength: 2),
        Region(name: "France", imageName: "🇫🇷", strength: 2)
    ]
    
    static let menus = [
        MenuItem(name: "Apps using VPN", imageName: "icloud.and.arrow.down"),
        MenuItem(name: "Rate us", imageName: "star"),
        MenuItem(name: "Support", imageName: "questionmark.circle"),
        MenuItem(name: "Settings", imageName: "gearshape"),
    ]
}

extension Color {
    static let appPrimary = Color.init(red: 84/255, green: 31/255, blue: 221/255)
    static let dropDown = Color.init(red: 28/255, green: 24/255, blue: 197/255)
    static let progressBackground = Color.init(red: 149/255, green: 112/255, blue: 250/255)
    static let progress = Color.init(red: 252/255, green: 229/255, blue: 96/255)
    static let darkPurple = Color.init(red: 169/255, green: 41/255, blue: 246/255)
    static let viewTop = Color.init(red: 187/255, green: 68/255, blue: 251/255)
    static let viewBottom = Color.init(red: 104/255, green: 36/255, blue: 242/255)
    static let stopColor = Color.init(red: 250/255, green: 140/255, blue: 82/255)
    
    static let progressLinear = LinearGradient(
        gradient: Gradient(colors:
                            [Color.progress,
                             Color.progress.opacity(0.01)]),
        startPoint: .leading,
        endPoint: .trailing)
    static let progressBackgroundLinear = LinearGradient(
        gradient: Gradient(colors:
                            [Color.progressBackground,
                             Color.progressBackground.opacity(0.01)]),
        startPoint: .top,
        endPoint: .bottom)
    
    static let sideBackground = LinearGradient(gradient: Gradient(colors: [Color.viewTop, Color.viewBottom]), startPoint: .top, endPoint: .bottom)
}

extension UIScreen {
   static let screenWidth   = UIScreen.main.bounds.size.width
   static let screenHeight  = UIScreen.main.bounds.size.height
   static let screenSize    = UIScreen.main.bounds.size
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
