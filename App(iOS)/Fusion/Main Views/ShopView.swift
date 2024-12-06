//
//  ShopView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 1/20/23.
//

import SwiftUI
//import StoreKit

struct ShopView: View
{
    @ObservedObject var user: User
        
    var body: some View
    {
        if user.isPro && !user.usedTrial
        {
            ProMemberShopView(user: user)
        }
        else
        {
            BasicMemberShopView(user: user)
        }
    }
}

struct ShopView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ShopView(user: User())
    }
}



struct BasicMemberShopView: View
{
    @ObservedObject var user: User
    
    @State private var showingTrialAlert = false
    @State private var showingComingSoonAlert = false
    
    var body: some View
    {
        VStack
        {
            Spacer()
            
            VStack
            {
                Text("Fusion")
                    .font(.title)
                    .fontWeight(.semibold)
                Text("PRO")
                    .font(.title)
                    .fontWeight(.semibold)
            }
            .padding()
            
            Text("Go PRO today to receive access to all the features Fusion has to offer. Enjoy the benefits of this lifetime membership for a one time purchase.") // of just $10.
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            Group
            {
                HStack
                {
                    Spacer()
                    Spacer()
                    Text("Basic")
                    Spacer()
                    Text("PRO")
                }
                .padding(.horizontal)
                Group
                {
                    Divider()
                    ZStack
                    {
                        HStack
                        {
                            Text("Ad Free")
                            Spacer()
                        }
                        .padding(.leading)
                        HStack
                        {
                            Spacer()
                            Spacer()
                            Text("✅")
                                .offset(x: -4)
                            Spacer()
                            Text("✅")
                                .offset(x: -5)
                        }
                        .padding(.trailing)
                    }
                }
                Group
                {
                    Divider()
                    ZStack
                    {
                        HStack
                        {
                            Text("Peer")
                            Spacer()
                        }
                        .padding(.leading)
                        HStack
                        {
                            Spacer()
                            Spacer()
                            Text("✅")
                                .offset(x: -4)
                            Spacer()
                            Text("✅")
                                .offset(x: -5)
                        }
                        .padding(.trailing)
                    }
                }
                Group
                {
                    Divider()
                    ZStack
                    {
                        HStack
                        {
                            Text("Host")
                            Spacer()
                        }
                        .padding(.leading)
                        HStack
                        {
                            Spacer()
                            Spacer()
                            Text("-")
                                .offset(x: -7)
                            Spacer()
                            Text("✅")
                                .offset(x: -5)
                        }
                        .padding(.trailing)
                    }
                }
                Group
                {
                    Divider()
                    ZStack
                    {
                        HStack
                        {
                            Text("Dynamic Background")
                            Spacer()
                        }
                        .padding(.leading)
                        HStack
                        {
                            Spacer()
                            Spacer()
                            Text("-")
                                .offset(x: -7)
                            Spacer()
                            Text("✅")
                                .offset(x: -5)
                        }
                        .padding(.trailing)
                    }
                }
                Group
                {
                    Divider()
                    ZStack
                    {
                        HStack
                        {
                            Text("Friends")
                            Spacer()
                        }
                        .padding(.leading)
                        HStack
                        {
                            Spacer()
                            Spacer()
                            Text("10")
                                .offset(x: -10)
                            Spacer()
                            // Make 1,000 when when certain
                            // of iCloud data rate safety
                            Text("100")
                                .offset(x: -20)
                        }
                        //.padding(.trailing)
                    }
                }
            }
            
            Spacer()
            
            if user.usedTrial
            {
                Button(action: purchasePro)
                {
                    Text("Buy Now")
                        .foregroundColor(Color.white)
                        .padding()
                        .background(.blue)
                        .clipShape(Capsule())
                }
                .padding()
                .alert(isPresented: $showingComingSoonAlert)
                {
                    Alert(title: Text("Coming Soon!"))
                }
                
                Text("Trial ends: \(Date.now < user.trialEndDate ? user.trialEndDate.formatted(date: .abbreviated, time: .shortened) : "Ended")")
            }
            else
            {
                Text("Not sure if you want Pro? Tap 'Use Trial' to try it free for 24 hours!")
                    .multilineTextAlignment(.center)
                
                HStack
                {
                    Button(action: purchasePro)
                    {
                        Text("Buy Now")
                            .foregroundColor(Color.white)
                            .padding()
                            .background(.blue)
                            .clipShape(Capsule())
                    }
                    .alert(isPresented: $showingComingSoonAlert)
                    {
                        Alert(title: Text("Coming Soon!"))
                    }
                    
                    Button(action: useTrial)
                    {
                        Text("Use Trial")
                            .foregroundColor(Color.white)
                            .padding()
                            .background(.blue)
                            .clipShape(Capsule())
                    }
                    .alert(isPresented: $showingTrialAlert)
                    {
                        Alert(
                            title: Text("Confirm Trial"),
                            message: Text("Be sure to start trial when you're with a friend. When trial ends, your membership will be returned back to Basic unless you purchase Pro. Continue?"),
                            primaryButton: .default(Text("Yes"))
                            {
                                print("Yes tapped.")
                                user.update(trialEndDate: Date(timeIntervalSinceNow: 86_400.0))
                                user.update(usedTrial: true)
                                user.update(isPro: true)
                            },
                            secondaryButton: .cancel())
                    }
                }
                .padding()
            }
            
            // Testing only
            Button("Reset Trial")
            {
                user.update(usedTrial: false)
            }
            .disabled(user.isPro == true)
        }
    }
    
    func purchasePro()
    {
        showingComingSoonAlert = true
    }
    
    func useTrial()
    {
        showingTrialAlert = true
    }
}

struct ProMemberShopView: View
{
    @ObservedObject var user: User
    
    var body: some View
    {
        Text("Welcome!")
    }
}
