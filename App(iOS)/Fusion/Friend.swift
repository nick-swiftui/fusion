//
//  Friend.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 5/8/23.
//

import Foundation

struct Friend: Codable, Identifiable, Equatable, Hashable
{
    let name: String
    let id: UUID
    
    var isSelected: Bool = false
}
