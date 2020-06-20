//
//  ExportableDataSourceContainer.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 6/19/20.
//

import RealmSwift

internal class ExportableDataSourceContainer<T: MembershipUser>: Object, Codable {
    
    internal private(set) var users: [T] = []
    
    internal typealias MembershipUserDictionary = [String: AnyObject]
    
    internal enum CodingKeys: String, CodingKey {
        case users
    }
    
    internal required init(from decoder: Decoder) throws  {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let usersList = try container.decode([T].self, forKey: .users)
        users.append(contentsOf: usersList)
        
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(users, forKey: .users)
    }
    
    internal required init() {
        super.init()
        initializeUsers()
    }
    
    private func initializeUsers() {
        do {
            let realm = try Realm()
            let allUsers = realm.objects(T.self)
            users = Array<T>(allUsers)
        } catch let error {
            DebugLogger.shared.addDebugMessage("Error getting user: \(error)")
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM-dd-yyyy-hh-mm"
        formatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    internal func convertDataSourceToUserListFile() -> URL? {
        
        do {
            let encodedDataSource: Data = try JSONEncoder().encode(users)
            
            let fileExtension: String = IOFileType.userList.fileExtension
            
            guard let filePath = createFilePath(withFileExtension: fileExtension) else {
                return nil
            }
            
            try encodedDataSource.write(to: filePath, options: Data.WritingOptions.atomicWrite)
            
            return filePath
            
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    internal func convertDataSourceToCSVFile() -> URL? {
        
        do {
            
            // Create file URL
            let fileExtension: String = IOFileType.csv.fileExtension
            
            guard let filePath = createFilePath(withFileExtension: fileExtension) else {
                return nil
            }
            
            // Create the CSV file's column headers (no spaces)
            // "userId,username,timeStampAdded,numVisits,timeStampOfLastVisit
            var csvText = T.variableNamesAsStrings().dropLast().joined(separator: ",") + "," + T.variableNamesAsStrings().last!
            
            // Convert all users to an array of JSON/Dictionary entries
            /*
                [
                    {
                       username: ....
                       userId: ....
                    },
                    and so on ....
                ]
             */
            guard let allUsersAsJSONArray: [MembershipUserDictionary] = getAllUsersAsJSONArray() else {
                return nil
            }

            // Loop through array of user JSON objects
            // Append each user's information as a new line in the CSV file
            for userObject: MembershipUserDictionary in allUsersAsJSONArray {
                
                let values: [String] = T.variableNamesAsStrings().map { (dictionaryKey) in
                    let dictionaryValue: AnyObject? = userObject[dictionaryKey]
                    return String(describing: dictionaryValue ?? "" as AnyObject)
                }
                
                let newLine = "\n" + values.dropLast().joined(separator: ",") + "," + values.last!
                csvText.append(newLine)
            }
            
            // Finally, write to the file URL and return it
            try csvText.write(to: filePath, atomically: true, encoding: String.Encoding.utf8)
            
            return filePath
            
        } catch let error {
            DebugLogger.shared.addDebugMessage("ExportableDataSourceContainer - Error converting data source to CSV: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func getAllUsersAsJSONArray() -> [MembershipUserDictionary]? {
        do {
            
            let encodedDataSource: Data = try JSONEncoder().encode(users)
            
            let result = try JSONSerialization.jsonObject(with: encodedDataSource, options: [])
            
            return result as? [MembershipUserDictionary]
        } catch {
            DebugLogger.shared.addDebugMessage("ExportableDataSourceContainer - Error encoding all users as JSON array: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func createFilePath(withFileExtension fileExtension: String) -> URL? {
        
        let formattedDate = ExportableDataSourceContainer.dateFormatter.string(from: Date())
        let fileName: String = "exported_membership_users_\(formattedDate)"
        
        let documents: [URL] = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory,
                                                        in: FileManager.SearchPathDomainMask.userDomainMask)
        
        guard let fileURL = documents.first else {
            DebugLogger.shared.addDebugMessage("ExportableDataSourceContainer - Error creating file URL")
            return nil
        }
        
        let pathComponent: String = "/\(fileName).\(fileExtension)"
        
        let filePath: URL = fileURL.appendingPathComponent(pathComponent)
        
        return filePath
    }
    
    
    
    
    
    
    /// Parse and return users from an imported IOFilleType.userList file
    internal static func importDataSource(at url: URL) -> [T]? {
        
        switch url.pathExtension {
        case IOFileType.userList.fileExtension:
            return parseImportedUserListFile(at: url)
        default: return nil
        }
    }
    
    private static func parseImportedUserListFile(at url: URL) -> [T]? {
        do {
            let importedDataSourceAsData = try Data(contentsOf: url)
            let users = try JSONDecoder().decode([T].self, from: importedDataSourceAsData)
            
            try FileManager.default.removeItem(at: url)
            
            return users
            
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
}
