//
//  AccountEditNameView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 7/17/23.
//

import SwiftUI

struct AccountEditNameView: View
{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var user: User
    @ObservedObject var songsQueue: SongsQueue
    
    @State private var displayName = ""
    
    enum NameError: Error
    {
        case count, contains, both
    }
    
    @State private var circleColor = Color.green
    @State private var nameIsValid = false
    
    var body: some View
    {
        ZStack
        {
            BackgroundView(user: user, songsQueue: songsQueue)
            
            VStack
            {
                HStack
                {
                    Text("Current Name: \(user.name)")
                    Spacer()
                }
                .padding([.leading, .trailing])
                
                VStack
                {
                    TextField("New Name", text: $displayName)
                        .textFieldStyle(.roundedBorder)
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
                        //.colorScheme(.light)
                    HStack
                    {
                        Spacer()
                        Text("\(displayName.count)/20")
                    }
                }
                .padding()
                
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
                
                Button(action: handleEnterNameButtonPressed)
                {
                    Text("Enter")
                        .padding([.leading, .trailing], 10)
                }
                .buttonStyle(.prominent)
                //.colorScheme(.light)
                .disabled(!nameIsValid)
            }
        }
    }
    
    func handleEnterNameButtonPressed()
    {
        user.update(name: displayName)
        displayName = ""
        
        self.presentationMode.wrappedValue.dismiss()
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
}

struct AccountEditNameView_Previews: PreviewProvider
{
    static var previews: some View
    {
        AccountEditNameView(user: User(), songsQueue: SongsQueue())
    }
}
