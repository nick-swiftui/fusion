//
//  User.swift
//  Fusion
//
//  Created by Nicolas Deleasa on 5/3/23.
//

import Foundation

import CloudKit

class User: ObservableObject, Codable
{
    enum CodingKeys: CodingKey
    {
        case name, hostID, searchID, permissions, friends, readyToGo, memberSince, appearance, isPro, usedTrial, trialEndDate
    }
    
    @Published var name: String
    {
        didSet
        {
            if let encoded = try? JSONEncoder().encode(self.name)
            {
                UserDefaults.standard.set(encoded, forKey: "User.name")
            }
        }
    }
    @Published var hostID: UUID
    {
        didSet
        {
            if let encoded = try? JSONEncoder().encode(self.hostID)
            {
                UserDefaults.standard.set(encoded, forKey: "User.hostID")
            }
        }
    }
    @Published var searchID: UUID
    {
        didSet
        {
            if let encoded = try? JSONEncoder().encode(self.searchID)
            {
                UserDefaults.standard.set(encoded, forKey: "User.searchID")
            }
        }
    }
    @Published var permissions: [String]
    {
        didSet
        {
            if let encoded = try? JSONEncoder().encode(self.permissions)
            {
                UserDefaults.standard.set(encoded, forKey: "User.permissions")
            }
        }
    }
    @Published var friends: [Friend]
    {
        didSet
        {
            if let encoded = try? JSONEncoder().encode(self.friends)
            {
                UserDefaults.standard.set(encoded, forKey: "User.friends")
            }
        }
    }
    @Published var readyToGo: Bool
    {
        didSet
        {
            if let encoded = try? JSONEncoder().encode(self.readyToGo)
            {
                UserDefaults.standard.set(encoded, forKey: "User.readyToGo")
            }
        }
    }
    @Published var memberSince: Date
    {
        didSet
        {
            if let encoded = try? JSONEncoder().encode(self.memberSince)
            {
                UserDefaults.standard.set(encoded, forKey: "User.memberSince")
            }
        }
    }
    @Published var appearance: String
    {
        didSet
        {
            if let encoded = try? JSONEncoder().encode(self.appearance)
            {
                UserDefaults.standard.set(encoded, forKey: "User.appearance")
            }
        }
    }
    @Published var isPro: Bool
    {
        didSet
        {
            if let encoded = try? JSONEncoder().encode(self.isPro)
            {
                UserDefaults.standard.set(encoded, forKey: "User.isPro")
            }
        }
    }
    @Published var usedTrial: Bool
    {
        didSet
        {
            if let encoded = try? JSONEncoder().encode(self.usedTrial)
            {
                UserDefaults.standard.set(encoded, forKey: "User.usedTrial")
            }
        }
    }
    @Published var trialEndDate: Date
    {
        didSet
        {
            if let encoded = try? JSONEncoder().encode(self.trialEndDate)
            {
                UserDefaults.standard.set(encoded, forKey: "User.trialEndDate")
            }
        }
    }
    
    var currentRecord: CKRecord?
    //let container = CKContainer.default()
    let database = CKContainer.default().privateCloudDatabase
    
    required init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        hostID = try container.decode(UUID.self, forKey: .hostID)
        searchID = try container.decode(UUID.self, forKey: .searchID)
        permissions = try container.decode([String].self, forKey: .permissions)
        friends = try container.decode([Friend].self, forKey: .friends)
        readyToGo = try container.decode(Bool.self, forKey: .readyToGo)
        memberSince = try container.decode(Date.self, forKey: .memberSince)
        appearance = try container.decode(String.self, forKey: .appearance)
        isPro = try container.decode(Bool.self, forKey: .isPro)
        usedTrial = try container.decode(Bool.self, forKey: .usedTrial)
        trialEndDate = try container.decode(Date.self, forKey: .trialEndDate)
    }

    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(hostID, forKey: .hostID)
        try container.encode(searchID, forKey: .searchID)
        try container.encode(permissions, forKey: .permissions)
        try container.encode(friends, forKey: .friends)
        try container.encode(readyToGo, forKey: .readyToGo)
        try container.encode(memberSince, forKey: .memberSince)
        try container.encode(appearance, forKey: .appearance)
        try container.encode(isPro, forKey: .isPro)
        try container.encode(usedTrial, forKey: .usedTrial)
        try container.encode(trialEndDate, forKey: .trialEndDate)
    }
    
    init()
    {
        // init name
        if let nameData = UserDefaults.standard.data(forKey: "User.name")
        {
            if let decoded = try? JSONDecoder().decode(String.self, from: nameData)
            {
                name = decoded
            }
            else
            {
                name = ""
                
                if let encoded = try? JSONEncoder().encode("")
                {
                    UserDefaults.standard.set(encoded, forKey: "User.name")
                }
            }
        }
        else
        {
            name = ""
            
            if let encoded = try? JSONEncoder().encode("")
            {
                UserDefaults.standard.set(encoded, forKey: "User.name")
            }
        }
        
        // init hostID
        if let hostIDData = UserDefaults.standard.data(forKey: "User.hostID")
        {
            if let decoded = try? JSONDecoder().decode(UUID.self, from: hostIDData)
            {
                hostID = decoded
            }
            else
            {
                let tempUUID = UUID()
                hostID = tempUUID
                
                if let encoded = try? JSONEncoder().encode(tempUUID)
                {
                    UserDefaults.standard.set(encoded, forKey: "User.hostID")
                }
            }
        }
        else
        {
            let tempUUID = UUID()
            hostID = tempUUID
            
            if let encoded = try? JSONEncoder().encode(tempUUID)
            {
                UserDefaults.standard.set(encoded, forKey: "User.hostID")
            }
        }
        
        // init searchID
        if let searchIDData = UserDefaults.standard.data(forKey: "User.searchID")
        {
            if let decoded = try? JSONDecoder().decode(UUID.self, from: searchIDData)
            {
                searchID = decoded
            }
            else
            {
                let tempUUID = UUID()
                searchID = tempUUID
                
                if let encoded = try? JSONEncoder().encode(tempUUID)
                {
                    UserDefaults.standard.set(encoded, forKey: "User.searchID")
                }
            }
        }
        else
        {
            let tempUUID = UUID()
            searchID = tempUUID
            
            if let encoded = try? JSONEncoder().encode(tempUUID)
            {
                UserDefaults.standard.set(encoded, forKey: "User.searchID")
            }
        }
        
        // init permissions
        if let permissionsData = UserDefaults.standard.data(forKey: "User.permissions")
        {
            if let decoded = try? JSONDecoder().decode([String].self, from: permissionsData)
            {
                permissions = decoded
            }
            else
            {
                let tempArray: [String] = []
                permissions = tempArray
                
                if let encoded = try? JSONEncoder().encode(tempArray)
                {
                    UserDefaults.standard.set(encoded, forKey: "User.permissions")
                }
            }
        }
        else
        {
            let tempArray: [String] = []
            permissions = tempArray
            
            if let encoded = try? JSONEncoder().encode(tempArray)
            {
                UserDefaults.standard.set(encoded, forKey: "User.permissions")
            }
        }
        
        // init friends
        if let friendsData = UserDefaults.standard.data(forKey: "User.friends")
        {
            if let decoded = try? JSONDecoder().decode([Friend].self, from: friendsData)
            {
                friends = decoded
            }
            else
            {
                let tempArray: [Friend] = []
                friends = tempArray
                
                if let encoded = try? JSONEncoder().encode(tempArray)
                {
                    UserDefaults.standard.set(encoded, forKey: "User.friends")
                }
            }
        }
        else
        {
            let tempArray: [Friend] = []
            friends = tempArray
            
            if let encoded = try? JSONEncoder().encode(tempArray)
            {
                UserDefaults.standard.set(encoded, forKey: "User.friends")
            }
        }
        
        // init readyToGo
        if let readyToGoData = UserDefaults.standard.data(forKey: "User.readyToGo")
        {
            if let decoded = try? JSONDecoder().decode(Bool.self, from: readyToGoData)
            {
                readyToGo = decoded
            }
            else
            {
                readyToGo = false
                
                if let encoded = try? JSONEncoder().encode(false)
                {
                    UserDefaults.standard.set(encoded, forKey: "User.readyToGo")
                }
            }
        }
        else
        {
            readyToGo = false
            
            if let encoded = try? JSONEncoder().encode(false)
            {
                UserDefaults.standard.set(encoded, forKey: "User.readyToGo")
            }
        }
        
        // init memberSince
        if let memberSinceData = UserDefaults.standard.data(forKey: "User.memberSince")
        {
            if let decoded = try? JSONDecoder().decode(Date.self, from: memberSinceData)
            {
                memberSince = decoded
            }
            else
            {
                let tempDate = Date()
                memberSince = tempDate
                
                if let encoded = try? JSONEncoder().encode(tempDate)
                {
                    UserDefaults.standard.set(encoded, forKey: "User.memberSince")
                }
            }
        }
        else
        {
            let tempDate = Date()
            memberSince = tempDate
            
            if let encoded = try? JSONEncoder().encode(tempDate)
            {
                UserDefaults.standard.set(encoded, forKey: "User.memberSince")
            }
        }
        
        // init appearance
        if let appearanceData = UserDefaults.standard.data(forKey: "User.appearance")
        {
            if let decoded = try? JSONDecoder().decode(String.self, from: appearanceData)
            {
                appearance = decoded
            }
            else
            {
                let tempString = "Light"
                appearance = tempString
                
                if let encoded = try? JSONEncoder().encode(tempString)
                {
                    UserDefaults.standard.set(encoded, forKey: "User.appearance")
                }
            }
        }
        else
        {
            let tempString = "Light"
            appearance = tempString
            
            if let encoded = try? JSONEncoder().encode(tempString)
            {
                UserDefaults.standard.set(encoded, forKey: "User.appearance")
            }
        }
        
        // init isPro
        if let isProData = UserDefaults.standard.data(forKey: "User.isPro")
        {
            if let decoded = try? JSONDecoder().decode(Bool.self, from: isProData)
            {
                isPro = decoded
            }
            else
            {
                isPro = false
                
                if let encoded = try? JSONEncoder().encode(false)
                {
                    UserDefaults.standard.set(encoded, forKey: "User.isPro")
                }
            }
        }
        else
        {
            isPro = false
            
            if let encoded = try? JSONEncoder().encode(false)
            {
                UserDefaults.standard.set(encoded, forKey: "User.isPro")
            }
        }
        
        // init usedTrial
        if let usedTrialData = UserDefaults.standard.data(forKey: "User.usedTrial")
        {
            if let decoded = try? JSONDecoder().decode(Bool.self, from: usedTrialData)
            {
                usedTrial = decoded
            }
            else
            {
                usedTrial = false
                
                if let encoded = try? JSONEncoder().encode(false)
                {
                    UserDefaults.standard.set(encoded, forKey: "User.usedTrial")
                }
            }
        }
        else
        {
            usedTrial = false
            
            if let encoded = try? JSONEncoder().encode(false)
            {
                UserDefaults.standard.set(encoded, forKey: "User.usedTrial")
            }
        }
        
        // init trialEndDate
        if let trialEndDateData = UserDefaults.standard.data(forKey: "User.trialEndDate")
        {
            if let decoded = try? JSONDecoder().decode(Date.self, from: trialEndDateData)
            {
                trialEndDate = decoded
            }
            else
            {
                let tempDate = Date()
                trialEndDate = tempDate
                
                if let encoded = try? JSONEncoder().encode(tempDate)
                {
                    UserDefaults.standard.set(encoded, forKey: "User.trialEndDate")
                }
            }
        }
        else
        {
            let tempDate = Date()
            trialEndDate = tempDate
            
            if let encoded = try? JSONEncoder().encode(tempDate)
            {
                UserDefaults.standard.set(encoded, forKey: "User.trialEndDate")
            }
        }
        
//        if let data = UserDefaults.standard.data(forKey: "User")
//        {
//            if let decoded = try? JSONDecoder().decode(User.self, from: data)
//            {
//                //guard let decodedName = decoded.name else { }
//                name = decoded.name
//                hostID = decoded.hostID
//                searchID = decoded.searchID
//                permissions = decoded.permissions
//                friends = decoded.friends
//                readyToGo = decoded.readyToGo
//                memberSince = decoded.memberSince
//                appearance = decoded.appearance
//                return
//            }
//        }
//
//        name = ""
//        hostID = UUID()
//        searchID = UUID()
//        permissions = []
//        friends = []
//        readyToGo = false
//        memberSince = Date()
//        appearance = "Light"
//
//        if let encoded = try? JSONEncoder().encode(self)
//        {
//            UserDefaults.standard.set(encoded, forKey: "User")
//        }
                
        fetchIcloudData()
        
//        /// async gets iCloud record name of logged-in user
//        func iCloudUserIDAsync(complete: (_ instance: CKRecord.ID?, _ error: NSError?) -> ())
//        {
//            let container = CKContainer.default()
//            container.fetchUserRecordID()
//            {
//                recordID, error in
//                if error != nil
//                {
//                    print("iCloudUserIDAsync error: \(error!.localizedDescription)")
//                    //complete(nil, error as NSError?)
//                }
//                else
//                {
//                    print("fetched ID \(recordID?.recordName ?? "nil")")
//                    //complete(recordID, nil)
//                }
//            }
//        }
//
//
//        // call the function above in the following way:
//        // (userID is the string you are intersted in!)
//
//        iCloudUserIDAsync()
//        {
//            recordID, error in
//            if let userID = recordID?.recordName
//            {
//                print("received iCloudID \(userID)")
//            }
//            else
//            {
//                print("Fetched iCloudID was nil")
//            }
//        }
        
//        if let currentRecord = currentRecord
//        {
//            database.modifyRecords(saving: [record], deleting: [currentRecord.recordID])
//            { (result: Result<(saveResults: [CKRecord.ID: Result<CKRecord, Error>], deleteResults: [CKRecord.ID: Result<Void, Error>]), Error>) in
//                switch result
//                {
//                case .success(let saveAndDeleteResults):
//                    // Handle the successful modification
//                    let saveResults = saveAndDeleteResults.saveResults
//                    let deleteResults = saveAndDeleteResults.deleteResults
//                    // Process the save and delete results as needed
//                case .failure(let error):
//                    // Handle the error
//                    print("Error modifying records: \(error.localizedDescription)")
//
//                    print(self.record.recordID)
//                }
//            }
//        }
    }
    
    func update(name: String)
    {
        self.name = name
    }
    
    func update(hostID: UUID)
    {
        self.hostID = hostID
    }
    
    func update(searchID: UUID)
    {
        self.searchID = searchID
    }
    
    func update(permissions: [String])
    {
        self.permissions = permissions
    }
    
    func add(friend: Friend)
    {
        self.friends.append(friend)
    }
    
//    func remove(friend: Friend)
//    {
//        //let friends = self.friends
//        self.friends.remove(at: self.friends.firstIndex(of: friend)!)
//    }
    
    func update(readyToGo: Bool)
    {
        self.readyToGo = readyToGo
    }
    
    func update(appearance: String)
    {
        self.appearance = appearance
    }
    
    func update(isPro: Bool)
    {
        self.isPro = isPro
    }
    
    func update(usedTrial: Bool)
    {
        self.usedTrial = usedTrial
    }
    
    func update(trialEndDate: Date)
    {
        self.trialEndDate = trialEndDate
    }
    
    func fetchIcloudData()
    {
        let record = CKRecord(recordType: "User")
        let query = CKQuery(recordType: "User", predicate: NSPredicate(value: true))
        
        database.fetch(withQuery: query)
        { result in
            switch result
            {
            case .success(let result):
                print("Got here.")
                
                // if iCloud is empty, make a save to iCloud.
                if result.matchResults.isEmpty
                {
                    print("Here is empty.")
                    
                    self.currentRecord = self.setRecordValues(record: record)
                    
                    if let currentRecord = self.currentRecord
                    {
                        self.saveRecord(with: currentRecord, database: self.database)
                    }
                    
                    return
                }
                
                result.matchResults.compactMap { $0.1 }
                    .forEach
                    {
                        switch $0
                        {
                        case .success(let record):
                            //currentRecord = record
                            self.currentRecord = record
                            //currentRecord["name"] = "Did this change?"
                            print("\nFetched iCloud Data\n---- ---- ---- ----")
                            print("Name: \(self.currentRecord!["name"] ?? "nil")\nHostID: \(self.currentRecord!["hostID"] ?? "nil")\nSearchID: \(self.currentRecord!["searchID"] ?? "nil")\nPermissions: \(self.currentRecord!["permissions"] ?? "nil")\nFriends: \(self.currentRecord!["friends"] ?? "nil")\nReadyToGo: \(self.currentRecord!["readyToGo"] ?? "nil")\nMemberSince: \(self.currentRecord!["memberSince"] ?? "nil")\nAppearance: \(self.currentRecord!["appearance"] ?? "nil")\nIsPro: \(self.currentRecord!["isPro"] ?? "nil")\nUsedTrial: \(self.currentRecord!["usedTrial"] ?? "nil")\nTrialEndDate: \(self.currentRecord!["trialEndDate"] ?? "nil")")
                            print("---- ---- ---- ----\n")
                            
                            // This executes when a previous user has data in iCloud
                            // and opens app for first time
                            // (whether from redownloading app or using new device).
                            if self.readyToGo == false
                            {
                                // Make readyToGo false so welcome view appears.
                                // Make welcome view disappear before enter name view appears
                                // by making readyToGo true if name.count != 0.
                                self.currentRecord!["readyToGo"] = 0
                                
                                self.assignIcloudData(record: self.currentRecord!)
                                
                                print("\nUser after func:\n ---- ---- ---- ----")
                                print("Name: \(self.name)\nHostID: \(self.hostID)\nSearchID: \(self.searchID)\nPermissions: \(self.permissions)\nFriends: \(self.friends)\nReadyToGo: \(self.readyToGo)\nMemberSince: \(self.memberSince)\nAppearance: \(self.appearance)\nIsPro: \(self.isPro)\nUsedTrial: \(self.usedTrial)\nTrialEndDate: \(self.trialEndDate)")
                                print("---- ---- ---- ----\n")
                                
                                return
                            }
                            
                            self.assignIcloudData(record: self.currentRecord!)
                            //self.saveRecord(with: self.setRecordValues(record: self.currentRecord!), database: database)
                            
                        case .failure(let error):
                            print("Error (2): \(error)")
                        }
                    }
            case .failure(let error):
                print("Error (1): \(error)")
            }
        }
    }
    
    func assignIcloudData(record: CKRecord)
    {
        if let name: String = record["name"],
           let hostID: String = record["hostID"],
           let searchID: String = record["searchID"],
           let permissions: [String] = record["permissions"],
           let friends: [String] = record["friends"],
           let readyToGo: Int = record["readyToGo"],
           let memberSince: Date = record["memberSince"],
           let appearance: String = record["appearance"],
           let isPro: Int = record["isPro"],
           let usedTrial: Int = record["usedTrial"],
           let trialEndDate: Date = record["trialEndDate"]
        {
            var formattedFriends: [Friend] = []
            for friend in friends
            {
                let properties: [String] = friend.components(separatedBy: ",")
                formattedFriends.append(Friend(name: properties[0], id: UUID(uuidString: properties[1])!, isSelected: properties[2] == "0" ? false : true))
            }
            
            //DispatchQueue.main.async
            DispatchQueue.main.sync
            {
                self.name = name
                self.hostID = UUID(uuidString: hostID)!
                self.searchID = UUID(uuidString: searchID)!
                self.permissions = permissions
                self.friends = formattedFriends
                self.readyToGo = readyToGo == 0 ? false : true
                self.memberSince = memberSince
                self.appearance = appearance
                self.isPro = isPro == 0 ? false : true
                self.usedTrial = usedTrial == 0 ? false : true
                self.trialEndDate = trialEndDate
                
                print("iCloud data assigned.")
            }
        }
        else
        {
            print("iCloud data not assigned.")
        }
    }
    
    func setRecordValues(record: CKRecord) -> CKRecord
    {
        //var friendsFormatted: [[String: Any]] = []
        var friendsFormatted: [String] = []
        
//        for friend in friends
//        {
//            var dictionary: [String: Any] = [:]
//            dictionary["name"] = friend.name
//            dictionary["id"] = friend.id.uuidString
//            dictionary["isSelected"] = friend.isSelected
//
//            friendsFormatted.append(dictionary)
//        }
        for friend in friends
        {
            friendsFormatted.append("\(friend.name),\(friend.id.uuidString),\(friend.isSelected ? "1" : "0")")
        }
        
        record.setValuesForKeys([
            "name": name,
            "hostID": hostID.uuidString,
            "searchID": searchID.uuidString,
            "permissions": permissions,
            "friends": friendsFormatted,
            "readyToGo": readyToGo,
            "memberSince": memberSince,
            "appearance": appearance,
            "isPro": isPro,
            "usedTrial": usedTrial,
            "trialEndDate": trialEndDate
        ])
        
        return record
    }
    
    func saveRecord(with record: CKRecord, database: CKDatabase)
    {
        database.save(record)
        { record, error in
            if let error = error as? CKError
            {
                // Handle error.
                print("iCloud save error.")
                print("Error (3): \(error)")
                if error.code == CKError.serverRecordChanged
                {
                    print("Error Code: Server Record Changed")
                    self.fetchIcloudData()
                }
                if error.code == CKError.networkFailure
                {
                    print("Error Code: Network Failure")
                }
                return
            }
            // Record saved successfully.
            print("iCloud save succeeded!")
        }
    }
}
