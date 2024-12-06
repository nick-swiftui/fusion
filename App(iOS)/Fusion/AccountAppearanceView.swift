//
//  AccountAppearanceView.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 6/16/23.
//

import SwiftUI

struct AccountAppearanceView: View
{
    @ObservedObject var user: User
    
    @ObservedObject var songsQueue: SongsQueue
    
    @State private var options: [Option] = [
        Option(title: "Light", isSelected: false),
        Option(title: "Dark", isSelected: false),
        Option(title: "Dynamic", isSelected: false)
    ]
    //Option(title: "Auto", isSelected: false),
    
    var body: some View
    {
        ZStack
        {
            BackgroundView(user: user, songsQueue: songsQueue)
            
            List
            {
                Section(footer: user.isPro ? Text("") : Text("To unlock dynamic, purchase the Pro membership from the shop."))
                {
                    ForEach(options, id: \.title)
                    { option in
                        Button(action:
                        {
                            selectOption(option)
                        })
                        {
                            HStack
                            {
                                if option.title == "Dynamic" && !user.isPro
                                {
                                    Text(option.title)
                                        .foregroundColor(.gray)
                                }
                                else
                                {
                                    Text(option.title)
                                        //.foregroundColor(.black)
                                        //.foregroundStyle(.primary)
                                        .foregroundColor(.primary)
                                }
                                Spacer()
                                if option.isSelected
                                {
                                    Image(systemName: "checkmark")
                                }
                                
                                if option.title == "Dynamic" && !user.isPro
                                {
                                    Image(systemName: "lock")
                                }
                            }
                        }
                        .disabled(option.title == "Dynamic" && !user.isPro)
                    }
                }
            }
            .navigationBarTitle(Text("Appearance"))
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(user.appearance == "Dynamic" ? .hidden : .visible)
            .onAppear
            {
                for option in options
                {
                    if option.title == user.appearance
                    {
                        let i = options.firstIndex(of: option)
                        options[i!].isSelected = true
                        return
                    }
                }
        }
        }
    }
    
    func selectOption(_ selectedOption: Option)
    {
        user.update(appearance: selectedOption.title)
        
        options = options.map
        { option in
            var mutableOption = option
            mutableOption.isSelected = option.title == selectedOption.title
            return mutableOption
        }
    }
}

struct AccountAppearanceView_Previews: PreviewProvider
{
    static var previews: some View
    {
        AccountAppearanceView(user: User(), songsQueue: SongsQueue())
    }
}




struct Option: Equatable
{
    let title: String
    var isSelected: Bool
}
