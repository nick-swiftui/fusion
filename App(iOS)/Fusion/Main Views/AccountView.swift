//
//  AccountView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 1/20/23.
//

import SwiftUI

struct AccountView: View
{
    @ObservedObject var user: User
    
    @ObservedObject var songsQueue: SongsQueue
    
    var body: some View
    {
        NavigationStack
        {
            ZStack
            {
                BackgroundView(user: user, songsQueue: songsQueue)
                
                List
                {
                    Section(header: user.isPro ? Text("PRO Member") : Text("Basic Member"), footer: Text("ID: \(user.hostID)"))
                    {
                        Text("Member since: \(user.memberSince.formatted(date: .abbreviated, time: .omitted))")
                    }
                    
                    Section(header: Text("Profile"))
                    {
                        NavigationLink
                        {
                            AccountEditNameView(user: user, songsQueue: songsQueue)
                        }
                    label:
                        {
                            Text("Name: \(user.name)")
                        }
                        //Text("ID: \(user.hostID)")
                        NavigationLink
                        {
                            AccountAppearanceView(user: user, songsQueue: songsQueue)
                        }
                    label:
                        {
                            Text("Appearance: \(user.appearance)")
                        }
                    }
                }
                .navigationTitle("Account")
                .scrollContentBackground(user.appearance == "Dynamic" ? .hidden : .visible)
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider
{
    static var previews: some View
    {
        AccountView(user: User(), songsQueue: SongsQueue())
    }
}



//VStack
//{
//    HStack
//    {
//        Text("Account")
//            .font(.title)
//            .fontWeight(.bold)
//            .padding()
//
//        Spacer()
//    }
//
//    Spacer()
//}





//List(options, id: \.title)
//{ option in
//    Button(action:
//    {
//        selectOption(option)
//    })
//    {
//        HStack
//        {
//            if option.title == "Dynamic"
//            {
//                Text(option.title)
//                    .foregroundColor(.gray)
//            }
//            else
//            {
//                Text(option.title)
//                    .foregroundColor(.black)
//            }
//            Spacer()
//            if option.isSelected
//            {
//                Image(systemName: "checkmark")
//            }
//
//            if option.title == "Dynamic"
//            {
//                Image(systemName: "lock")
//            }
//        }
//    }
//    .disabled(option.title == "Dynamic")
//}
