//
//  ExportableDataSourceContainer.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 6/19/20.
//

import RealmSwift

internal class ExportableDataSourceContainer<T: MembershipUser>: Object, Codable {
    
    internal private(set) var users: [T] = []
    
    internal typealias MembershipUserDictionary = [String: Any]
    
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
        
        guard let allUsers = Club.shared.queryForUsers(ofType: T.self, predicate: nil) else {
            let error = CKError.invalidRealmLayer("Failed to initialize Realm instance")
            DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - Error getting user: \(error)")
            return
        }
        users = Array<T>(allUsers)
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
                    let dictionaryValue = userObject[dictionaryKey]
                    return String(describing: dictionaryValue ?? "" as AnyObject)
                }
                
                let newLine = "\n" + values.dropLast().joined(separator: ",") + "," + values.last!
                csvText.append(newLine)
            }
            
            // Finally, write to the file URL and return it
            try csvText.write(to: filePath, atomically: true, encoding: String.Encoding.utf8)
            
            return filePath
            
        } catch let error {
            DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - Error converting data source to CSV: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func getAllUsersAsJSONArray() -> [MembershipUserDictionary]? {
        do {
            
            let encodedDataSource: Data = try JSONEncoder().encode(users)
            
            let result = try JSONSerialization.jsonObject(with: encodedDataSource, options: [])
            
            return result as? [MembershipUserDictionary]
        } catch {
            DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - Error encoding all users as JSON array: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func createFilePath(withFileExtension fileExtension: String) -> URL? {
        
        let formattedDate = ExportableDataSourceContainer.dateFormatter.string(from: Date())
        let fileName: String = "exported_membership_users_\(formattedDate)"
        
        let documents: [URL] = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory,
                                                        in: FileManager.SearchPathDomainMask.userDomainMask)
        
        guard let documentsURL = documents.first else {
            DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - Error creating file URL")
            return nil
        }
        
        let pathComponent: String = "/\(fileName).\(fileExtension)"
        
        let filePath: URL = documentsURL.appendingPathComponent(pathComponent)
        
        return filePath
    }
    
    
    
    
    
    
    /// Parse and return users from an imported IOFilleType.userList file
    internal static func importDataSource(at url: URL) -> [T]? {
        
        switch url.pathExtension {
        case IOFileType.userList.fileExtension:
            return parseImportedUserListFile(at: url)
        case IOFileType.csv.fileExtension:
            return parseImportedUserCSVFile(at: url)
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
            DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - Error converting data in URL to Users. Error: \(error)")
            return nil
        }
    }
    
    private static func parseImportedUserCSVFile(at url: URL) -> [T]? {
        guard let csvRows = getCSVRows(from: url) else {
            return nil
        }
        
        guard let columnNames: [String] = csvRows.first?.components(separatedBy: ",") else {
            return nil
        }
        
        let userRows: [String] = Array<String>(csvRows[1..<csvRows.count])
        
        let arrayOfDictionaries: [MembershipUserDictionary] = convertToDictionaryArray(csvLines: userRows, columnNames: columnNames)
        
        guard let contentsAsJsonString: String = convertToJSONString(array: arrayOfDictionaries) else {
            return nil
        }
        
        try? FileManager.default.removeItem(at: url)
        
        return getUsersFrom(jsonString: contentsAsJsonString)
    }
    
    private static func getCSVRows(from url: URL) -> [String]? {
        do {
            let contents = try String(contentsOf: url, encoding: String.Encoding.utf8)
            
            let csvRows: [String] = contents.components(separatedBy: .newlines)
            
            return csvRows
        } catch let error {
            DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - Error getting CSV rows from URL. Error: \(error)")
            return nil
        }
    }
    
    private static func convertToDictionaryArray(csvLines: [String], columnNames: [String]) -> Array<MembershipUserDictionary> {
        var result = Array<MembershipUserDictionary>()
        
        for line in csvLines {
            let fieldValues = line.components(separatedBy: ",")
            // NOTE
            // This assumes all the field values (columns) are Strings
            // This also assumes a sort of "generic" format
            // If your data contains Integers, Floats, etc, you should
            // parse them individually
            // For example, if you know the third column is an integer:
            // let value = Int(fieldValues[2])
            // Or, alternatively, when decoding User objects, cast the decoded String
            // back to an integer
            let dictionary = Dictionary(zip(columnNames, fieldValues), uniquingKeysWith: { (first, _) in first })
            result.append(dictionary)
        }
        return result
    }
    
    private static func convertToJSONString(array: [MembershipUserDictionary]) -> String? {
        do {
            let jsonData: Data = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
            return String(data: jsonData, encoding: String.Encoding.utf8)
        } catch let error {
            DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - Error converting Users to JSON string. Error: \(error)")
            return nil
        }
    }
    
    private static func getUsersFrom(jsonString: String) -> [T]? {
        guard let importedDataSourceAsData: Data = jsonString.data(using: String.Encoding.utf8) else {
            return nil
        }
        do {
            let users = try JSONDecoder().decode([T].self, from: importedDataSourceAsData)
            return users
        } catch let error {
            DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - Error converting JSON data to Users. Error: \(error)")
            return nil
        }
    }
    
}
