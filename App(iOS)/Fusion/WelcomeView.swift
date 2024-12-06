//
//  WelcomeView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 1/11/23.
//

// Abstract:
// A view that introduces the purpose of the app to users.

import MusicKit
import SwiftUI

import CoreBluetooth

// MARK: - Welcome view

/// `WelcomeView` is a view that introduces to users the purpose of the Fusion app,
/// and demonstrates best practices for requesting user consent for an app to get access to
/// Apple Music data.
///
/// Present this view as a sheet using the convenience `.welcomeSheet()` modifier.
struct WelcomeView: View
{
    
    // MARK: - Properties
    
    /// The current authorization status of MusicKit.
    @Binding var musicAuthorizationStatus: MusicAuthorization.Status
    
    /// The current authorization status of CoreBluetooth.
    @Binding var bluetoothAuthorizationStatus: CBManagerAuthorization
    
    /// The current authorization status of this app.
    @Binding var appAuthorizationStatus: Bool
    
    /// Opens a URL using the appropriate system service.
    @Environment(\.openURL) private var openURL
    
    // The User class
    @ObservedObject var user: User
    
    @State var bluetoothPeripheral: BluetoothPeripheral?
    
    @State private var displayName = ""
    
    @State private var isShowingEnterNameView = false
    
    @State private var isShowingNotificationView = false
    
    enum NameError: Error
    {
        case count, contains, both
    }
    
    @State private var circleColor = Color.green
    @State private var nameIsValid = false
    
    // MARK: - View
    
    /// A declaration of the UI that this view presents.
    var body: some View
    {
        ZStack
        {
            gradient
            VStack
            {
                Text("Fusion")
                    .foregroundColor(.primary)
                    .font(.largeTitle.weight(.semibold))
                    .shadow(radius: 2)
                    .padding(.bottom, 1)
                Text("Fuse into one.")
                    .foregroundColor(.primary)
                    .font(.title2.weight(.medium))
                    .multilineTextAlignment(.center)
                    .shadow(radius: 1)
                    .padding(.bottom, 16)
                explanatoryText
                    .foregroundColor(.primary)
                    .font(.title3.weight(.medium))
                    .multilineTextAlignment(.center)
                    .shadow(radius: 1)
                    .padding([.leading, .trailing], 32)
                    .padding(.bottom, 16)
                if let secondaryExplanatoryText = self.secondaryExplanatoryText
                {
                    secondaryExplanatoryText
                        .foregroundColor(.primary)
                        .font(.title3.weight(.medium))
                        .multilineTextAlignment(.center)
                        .shadow(radius: 1)
                        .padding([.leading, .trailing], 32)
                        .padding(.bottom, 16)
                }
                if musicAuthorizationStatus == .notDetermined || musicAuthorizationStatus == .denied
                {
                    Button(action: handleButtonPressed)
                    {
                        buttonText
                            .padding([.leading, .trailing], 10)
                    }
                    .buttonStyle(.prominent)
                    .colorScheme(.light)
                }
            }
            .colorScheme(.dark)
            
            if musicAuthorizationStatus == .authorized
            {
                ZStack
                {
                    gradient
                    VStack
                    {
                        bluetoothExplanatoryText
                            .foregroundColor(.primary)
                            .font(.title3.weight(.medium))
                            .multilineTextAlignment(.center)
                            .shadow(radius: 1)
                            .padding([.leading, .trailing], 32)
                            .padding(.bottom, 16)
                        if let secondaryBluetoothExplanatoryText = self.secondaryBluetoothExplanatoryText
                        {
                            secondaryBluetoothExplanatoryText
                                .foregroundColor(.primary)
                                .font(.title3.weight(.medium))
                                .multilineTextAlignment(.center)
                                .shadow(radius: 1)
                                .padding([.leading, .trailing], 32)
                                .padding(.bottom, 16)
                        }
                        if bluetoothAuthorizationStatus == .notDetermined || bluetoothAuthorizationStatus == .denied
                        {
                            Button(action: handleBluetoothButtonPressed)
                            {
                                bluetoothButtonText
                                    .padding([.leading, .trailing], 10)
                            }
                            .buttonStyle(.prominent)
                            .colorScheme(.light)
                        }
                    }
                    .colorScheme(.dark)
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification))
                    { _ in
                        let status = CBManager.authorization

                        if status == .allowedAlways
                        {
                            withAnimation
                            {
                                isShowingNotificationView = true
                            }

                            bluetoothPeripheral = nil
                        }
                        else if status == .denied
                        {
                            update(bluetoothAuthorizationStatus: status)
                        }
                    }
                }
                .transition(.move(edge: .trailing))
            }
            
            if isShowingNotificationView
            {
                ZStack
                {
                    gradient
                    VStack
                    {
                        notificationExplanatoryText
                            .foregroundColor(.primary)
                            .font(.title3.weight(.medium))
                            .multilineTextAlignment(.center)
                            .shadow(radius: 1)
                            .padding([.leading, .trailing], 32)
                            .padding(.bottom, 16)
                        
                        Button(action: handleNotificationButtonPressed)
                        {
                            notificationButtonText
                                .padding([.leading, .trailing], 10)
                        }
                        .buttonStyle(.prominent)
                        .colorScheme(.light)
                    }
                    .colorScheme(.dark)
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification))
                    { _ in
                        withAnimation
                        {
                            if user.name.count == 0
                            {
                                isShowingEnterNameView = true
                            }
                            else
                            {
                                appAuthorizationStatus = true
                                user.update(readyToGo: true)
                            }
                        }
                    }
                }
                .transition(.move(edge: .trailing))
            }
            
            if isShowingEnterNameView
            {
                ZStack
                {
                    gradient
                    VStack
                    {
                        Text("Enter name below:")
                            .foregroundColor(.primary)
                            .font(.title3.weight(.medium))
                            .multilineTextAlignment(.center)
                            .shadow(radius: 1)
                            .padding([.leading, .trailing], 32)
                            .padding(.bottom, 16)
                        VStack
                        {
                            TextField("Display Name", text: $displayName)
                                //.padding()
                                .textFieldStyle(.roundedBorder)
                                .colorScheme(.light)
                                .onChange(of: displayName)
                                { newValue in
                                    do
                                    {
                                        let result = try checkNameIsValid(with: newValue)
                                        nameIsValid = result
                                        circleColor = result == true ? Color.green : Color.red
                                    }
                                    catch NameError.both
                                    {
                                        nameIsValid = false
                                        circleColor = .red
                                    }
                                    catch NameError.count
                                    {
                                        nameIsValid = false
                                        circleColor = .green
                                    }
                                    catch NameError.contains
                                    {
                                        nameIsValid = false
                                        circleColor = .red
                                    }
                                    catch
                                    {
                                        print("There was an error.")
                                    }
                                }
                            HStack
                            {
                                Spacer()
                                Text("\(displayName.count)/20")
                            }
                            
                            VStack
                            {
                                HStack
                                {
                                    Circle()
                                        .frame(width: 10)
                                        .foregroundColor(circleColor)
                                    Text("Only contains a-z, 0-9, ( _ ), [SPACE]")
                                    Spacer()
                                }
                            }
                            .padding(.leading)
                        }
                        .padding()
                        Button(action: handleEnterNameButtonPressed)
                        {
                            Text("Enter")
                                .padding([.leading, .trailing], 10)
                        }
                        .buttonStyle(.prominent)
                        .colorScheme(.light)
                        .disabled(!nameIsValid)
                    }
                    .colorScheme(.dark)
                }
                .transition(.move(edge: .trailing))
            }
        }
    }
    
    /// Constructs a gradient to use as the view background.
    private var gradient: some View
    {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: (130.0 / 255.0), green: (109.0 / 255.0), blue: (204.0 / 255.0)),
                Color(red: (130.0 / 255.0), green: (130.0 / 255.0), blue: (211.0 / 255.0)),
                Color(red: (131.0 / 255.0), green: (160.0 / 255.0), blue: (218.0 / 255.0))
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .flipsForRightToLeftLayoutDirection(false)
        .ignoresSafeArea()
    }
    
    /// Provides text that explains how to use the app according to the authorization status.
    private var explanatoryText: Text
    {
        let explanatoryText: Text
        switch musicAuthorizationStatus
        {
            case .restricted:
                explanatoryText = Text("Fusion cannot be used on this iPhone because usage of ")
                    + Text(Image(systemName: "applelogo")) + Text(" Music is restricted.")
            default:
                explanatoryText = Text("Fusion uses ")
                    + Text(Image(systemName: "applelogo")) + Text(" Music\nto help you fuse with your friends to play music on the same speaker with your own device.")
        }
        return explanatoryText
    }
    
    /// Provides additional text that explains how to get access to Apple Music
    /// after previously denying authorization.
    private var secondaryExplanatoryText: Text?
    {
        var secondaryExplanatoryText: Text?
        switch musicAuthorizationStatus
        {
            case .denied:
                secondaryExplanatoryText = Text("Please grant Fusion access to ")
                    + Text(Image(systemName: "applelogo")) + Text(" Music in Settings.")
            default:
                break
        }
        return secondaryExplanatoryText
    }
    
    /// A button that the user taps to continue using the app according to the current
    /// authorization status.
    private var buttonText: Text
    {
        let buttonText: Text
        switch musicAuthorizationStatus
        {
            case .notDetermined:
                buttonText = Text("Continue")
            case .denied:
                buttonText = Text("Open Settings")
            default:
                fatalError("No button should be displayed for current authorization status: \(musicAuthorizationStatus).")
        }
        return buttonText
    }
    
    private var bluetoothExplanatoryText: Text
    {
        let bluetoothExplanatoryText: Text
        switch bluetoothAuthorizationStatus
        {
        case .restricted:
            bluetoothExplanatoryText = Text("Fusion cannot be used on this iPhone because usage of Bluetooth is restricted.")
        default:
            bluetoothExplanatoryText = Text(" Fusion uses Bluetooth\nto help you fuse with your friends to play music on the same speaker with your own device.")
        }
        return bluetoothExplanatoryText
    }
    
    /// Provides additional text that explains how to get access to Bluetooth
    /// after previously denying authorization.
    private var secondaryBluetoothExplanatoryText: Text?
    {
        var secondaryBluetoothExplanatoryText: Text?
        switch bluetoothAuthorizationStatus
        {
        case .denied:
            secondaryBluetoothExplanatoryText = Text("Please grant Fusion access to Bluetooth in Settings.")
        default:
            break
        }
        return secondaryBluetoothExplanatoryText
    }
    
    /// A button that the user taps to continue using the app according to the current
    /// authorization status.
    private var bluetoothButtonText: Text
    {
        let bluetoothButtonText: Text
        switch bluetoothAuthorizationStatus
        {
            case .notDetermined:
                bluetoothButtonText = Text("Continue")
            case .denied:
                bluetoothButtonText = Text("Open Settings")
            default:
                fatalError("No button should be displayed for current authorization status: \(bluetoothAuthorizationStatus).")
        }
        return bluetoothButtonText
    }
    
    private var notificationExplanatoryText: Text
    {
        Text("Allow notifications so you can be notified about things like someone trying to fuse with you while you're away from the app.")
    }
    
    private var notificationButtonText: Text
    {
        Text("Continue")
    }
    
    // MARK: - Methods
    
    /// Allows the user to authorize Apple Music usage when tapping the Continue/Open Setting button.
    private func handleButtonPressed()
    {
        switch musicAuthorizationStatus
        {
            case .notDetermined:
                Task
                {
                    let musicAuthorizationStatus = await MusicAuthorization.request()
                    await update(with: musicAuthorizationStatus)
                }
            case .denied:
                if let settingsURL = URL(string: UIApplication.openSettingsURLString)
                {
                    openURL(settingsURL)
                }
            default:
                fatalError("No button should be displayed for current authorization status: \(musicAuthorizationStatus).")
        }
    }
    
    /// Allows the user to authorize Bluetooth usage when tapping the Continue/Open Setting button.
    private func handleBluetoothButtonPressed()
    {
        switch bluetoothAuthorizationStatus
        {
            case .notDetermined:
                Task
                {
                    bluetoothPeripheral = BluetoothPeripheral()
                    bluetoothPeripheral?.toggleChanged()
                }
            case .denied:
                if let settingsURL = URL(string: UIApplication.openSettingsURLString)
                {
                    openURL(settingsURL)
                }
            default:
                fatalError("No button should be displayed for current authorization status: \(bluetoothAuthorizationStatus).")
        }
    }
            
    private func handleNotificationButtonPressed()
    {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        { success, error in
            if success
            {
                print("All set!")
            }
            else if let error = error
            {
                print(error.localizedDescription)
            }
        }
    }
    
    private func handleEnterNameButtonPressed()
    {
        appAuthorizationStatus = true
        user.update(name: displayName)
        displayName = ""
        
        user.update(readyToGo: true)
    }
    
    /// Safely updates the `musicAuthorizationStatus` property on the main thread.
    @MainActor
    private func update(with musicAuthorizationStatus: MusicAuthorization.Status)
    {
        withAnimation
        {
            self.musicAuthorizationStatus = musicAuthorizationStatus
        }
    }
    
    /// Safely updates the `bluetoothAuthorizationStatus` property on the main thread.
    @MainActor
    private func update(bluetoothAuthorizationStatus: CBManagerAuthorization)
    {
        withAnimation
        {
            self.bluetoothAuthorizationStatus = bluetoothAuthorizationStatus
        }
    }
    
    func checkNameIsValid(with name: String) throws -> Bool
    {
        // Only allow 1-20 char
        // a-z, 0-9, _
        let characterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_ ")
        
        if (name.count == 0 || name.count > 20) && name.rangeOfCharacter(from: characterSet.inverted) != nil
        {
            throw NameError.both
        }
        else if (name.count == 0 || name.count > 20)
        {
            throw NameError.count
        }
        else if name.rangeOfCharacter(from: characterSet.inverted) != nil
        {
            throw NameError.contains
        }
        
        return true
    }
    
//    // MARK: - Presentation coordinator
//
//    /// A presentation coordinator to use in conjuction with `SheetPresentationModifier`.
//    class PresentationCoordinator: ObservableObject
//    {
//        static let shared = PresentationCoordinator()
//
//        private init()
//        {
//            let authorizationStatus = MusicAuthorization.currentStatus
//            musicAuthorizationStatus = authorizationStatus
//            isWelcomeViewPresented = (authorizationStatus != .authorized)
//        }
//
//        @Published var musicAuthorizationStatus: MusicAuthorization.Status
//        {
//            didSet
//            {
//                isWelcomeViewPresented = (musicAuthorizationStatus != .authorized)
//            }
//        }
//
//        @Published var isWelcomeViewPresented: Bool
//    }
//
//    // MARK: - Sheet presentation modifier
//
//    /// A view modifier that changes the presentation and dismissal behavior of the welcome view.
//    fileprivate struct SheetPresentationModifier: ViewModifier
//    {
//        @StateObject private var presentationCoordinator = PresentationCoordinator.shared
//
//        func body(content: Content) -> some View
//        {
//            content
//                .sheet(isPresented: $presentationCoordinator.isWelcomeViewPresented)
//                {
//                    WelcomeView(musicAuthorizationStatus: $presentationCoordinator.musicAuthorizationStatus)
//                        .interactiveDismissDisabled()
//                }
//        }
//    }
    
    // MARK: - Presentation coordinator
    
    /// A presentation coordinator to use in conjuction with `SheetPresentationModifier`.
    class PresentationCoordinator: ObservableObject
    {
        @ObservedObject var user: User
        
        init(user: User)
        {
            self.user = user
            
            let authorizationStatus = user.name.isEmpty == false
            appAuthorizationStatus = authorizationStatus
            isWelcomeViewPresented = (authorizationStatus != true)
            
            musicAuthorizationStatus = MusicAuthorization.currentStatus
            bluetoothAuthorizationStatus = CBManager.authorization
        }
        
        @Published var musicAuthorizationStatus: MusicAuthorization.Status
        
        @Published var bluetoothAuthorizationStatus: CBManagerAuthorization
        
        @Published var appAuthorizationStatus: Bool
        {
            didSet
            {
                isWelcomeViewPresented = (appAuthorizationStatus != true)
            }
        }
        
        @Published var isWelcomeViewPresented: Bool
    }
    
    // MARK: - Sheet presentation modifier
    
    /// A view modifier that changes the presentation and dismissal behavior of the welcome view.
    fileprivate struct SheetPresentationModifier: ViewModifier
    {
        @ObservedObject var user: User
        
        @StateObject private var presentationCoordinator: PresentationCoordinator
        
        func body(content: Content) -> some View
        {
            content
                .sheet(isPresented: $presentationCoordinator.isWelcomeViewPresented)
                {
                    WelcomeView(musicAuthorizationStatus: $presentationCoordinator.musicAuthorizationStatus, bluetoothAuthorizationStatus: $presentationCoordinator.bluetoothAuthorizationStatus, appAuthorizationStatus: $presentationCoordinator.appAuthorizationStatus, user: user)
                        .interactiveDismissDisabled()
                }
        }
        
        init(user: User)
        {
            self.user = user
            _presentationCoordinator = StateObject(wrappedValue: PresentationCoordinator(user: user))
        }
    }
}

//// MARK: - View extension
//
///// Allows the addition of the`welcomeSheet` view modifier to the top-level view.
//extension View
//{
//    func welcomeSheet() -> some View
//    {
//        modifier(WelcomeView.SheetPresentationModifier())
//    }
//}

// MARK: - View extension

/// Allows the addition of the`welcomeSheet` view modifier to the top-level view.
extension View
{
    func welcomeSheet(user: User) -> some View
    {
        modifier(WelcomeView.SheetPresentationModifier(user: user))
    }
}

// MARK: - Previews

//struct WelcomeView_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        WelcomeView(musicAuthorizationStatus: .constant(.notDetermined), user: User())
//    }
//}






// Bluetooth Permission and enter name section
