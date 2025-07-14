//
//  FirestoreManager.swift
//  Wheely
//
//  Created by 민현규 on 7/11/25.
//

import Foundation
import FirebaseFirestore

enum CacheError: Error {
    case nameNotFound
    case dataNotFound
    case dateAlreadyExist
    case nameAlreadyExist
}

enum FirestoreError: Error {
    case internalError
    case failedToGetData
    case failedUnwrapData
    case firebase(code: FirestoreErrorCode.Code)
}

class DataManager {
    
}

// 일단 에러 처리는 나중에 하자.
// uid -> [Name : [FirestoreData]]
class FirestoreManager {
    let db = Firestore.firestore()
    let collection = "Data"
    let uid: String
    
    public func get() async -> [String: [FirestoreData]]? {
        let result: [String: [FirestoreData]]? = await withCheckedContinuation { continuation in
            db.collection(collection).document(uid).getDocument { document, error in
                if let error = error {
                    print("Error occurred: \(error)")
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let document = document else {
                    print("Failed to fetch document.")
                    continuation.resume(returning: nil)
                    return
                }
                print(document.exists)
                guard let data = document.data() as? [String: [String]] else {
                    print("Failed to casting document data.")
                    continuation.resume(returning: nil)
                    return
                }
                print(data)
                let formatter = FirestoreFormater()
                let result = try? formatter.makeToFirestoreData(data)
                continuation.resume(returning: result)
            }
        }
        return result
    }
    
    /// Dictonary안의 키들을 모두 가져옵니다.
    private func getKeys(_ dict: [String : Any]) -> [String] {
        let keys = Array(dict.keys)
        return keys
    }
    
    init(uid: String) {
        self.uid = uid
    }
}


class CacheManager {
    
    private var cache: [String: [FirestoreData]] = [:]
    /// 특정 시간의 데이터를 가져옵니다.
    ///
    /// - Throws: 만약 해당하는 날짜를 찾지 못했을시 FirestoreError.dataNotFound를 throw합니다.
    ///
    /// - Parameters:
    ///     - time: 찾을 대상의 시간.
    func getData(_ name: String, time: Date) throws -> FirestoreData {
        guard let dataArray = cache[name] else { throw CacheError.nameNotFound }
        
        for d in dataArray {
            if d.date == time {
                return d
            }
        }
        
        throw CacheError.dataNotFound
    }
    
    /// 도큐먼트 안의 모든 내용을 가져옵니다.
    func getAllData(_ name: String) throws -> [FirestoreData] {
        guard let dataArray = cache[name] else { throw CacheError.nameNotFound }
        return dataArray
    }
    
    /// 하나의 데이터만 업데이트 합니다.
    ///
    /// 어떤 데이터를 업데이트할지는 FirestoreData의 날짜를 보고 판단합니다.
    ///
    /// - Throws: 만약 해당하는 날짜를 찾지 못했을시 FirestoreError.dataNotFound를 throw합니다.
    ///
    /// - Parameters:
    ///     - name: 이름
    ///     - data: 값을 업데이트할 데이터
    ///
    func updateData(_ name: String, data: FirestoreData) throws {
        guard var dataArray = cache[name] else { throw CacheError.nameNotFound }
        
        for index in 0..<dataArray.count {
            if dataArray[index].date == data.date {
                dataArray[index] = data
                break
            }
        }
        
    }
    
    /// FirestoreData를 배열로 받아 여러개의 데이터를 한꺼번에 업데이트 합니다.
    ///
    /// 만약 업데이트할 데이터를 캐시에서 찾지 못했을시, 그 값은 그냥 무시되며 그 값이 배열로 반환됩니다.
    func updateDatas(_ name: String, datas: [FirestoreData]) throws -> [FirestoreData] {
        var ignoredDatas: [FirestoreData] = []
        let dataArray = self.cache[name]
        guard var dataArray = dataArray else { throw CacheError.nameNotFound }
        for data in datas {
            var founded = false
            for index in 0..<dataArray.count {
                if dataArray[index].date == data.date {
                    founded = true
                    dataArray[index] = data
                    break
                }
            }
            if !founded {
                ignoredDatas.append(data)
            }
            
        }
        
        return ignoredDatas
        
    }
    
    /// 캐시에 새로운 데이터를 추가합니다.
    ///
    /// - Parameters:
    ///     - data: 추가할 데이터
    /// - Throws:
    ///     - 만약 같은 날짜의 데이터가 이미 존재하면 CacheError.dataAlreadyExist 에러를 throw합니다.
    func addData(_ name: String, data: FirestoreData) throws {
        guard var dataArray = cache[name] else {
            throw CacheError.nameNotFound
        }
        
        // 같은 날짜의 데이터가 이미 있는지 확인합니다.
        for d in dataArray {
            if d.date == data.date {
                throw CacheError.dateAlreadyExist
            }
        }
        
        dataArray.append(data)
    }
    
    /// 캐시에 있는 데이터를 제거합니다.
    ///
    /// - Parameters:
    ///     - data: 제거할 데이터
    func removeData(_ name: String, data: FirestoreData) throws {
        guard var dataArray = cache[name] else {
            throw CacheError.nameNotFound
        }
        
        for index in 0..<dataArray.count {
            if dataArray[index].date == data.date {
                dataArray.remove(at: index)
                return
            }
        }
        
        throw CacheError.dataNotFound
    }
    
    /// 도큐먼트 안의 내용을 모두 덮어씁니다.
    ///
    /// - Important: name 도큐먼트가 생성되어 있어야 합니다.
    ///
    /// - Parameters:
    ///     - name: 이름
    ///     - datas: 덮어쓸 데이터 배열
    func overwriteAllData(_ name: String, datas: [FirestoreData]) throws {
        guard let _ = cache[name] else {
            throw CacheError.nameNotFound
        }
        
        cache[name] = datas
    }
    
    /// 새로운 이름(Document)를 생성합니다.
    ///
    /// - Throws: 이미 같은 이름이 존재할경우 CacheError.nameAlreadyExist 를 throw합니다.
    func makeDocument(_ name: String) throws {
        if let _ = cache[name] {
            // 같은 이름이 이미 존재.
            throw CacheError.nameAlreadyExist
        } else {
            cache[name] = []
        }
    }
    
    init(cache: [String : [FirestoreData]]) {
        self.cache = cache
    }
}

struct FirestoreData {
    let date: Date
    let values: [Double]
}

class FirestoreFormater: TimeManager {
    
    func makeDataToString(_ dataObject: FirestoreData) -> String {
        let date = dataObject.date
        let values = dataObject.values
        
        var result = ""
        result.append("\(self.convertToISO(date)) ")
        for value in values {
            result.append("\(value) ")
        }
        _ = result.popLast() // remove last whitespace
        return result
    }
    
    func parseStringToData(stringValue: String) throws -> FirestoreData {
        var splited = stringValue.split(separator: " ")
        
        // Get time from String
        let time: Date = try self.convertISOToDate(String(splited[0]))
        // And remove it for forloop
        splited.remove(at: 0)
        
        var values: [Double] = []
        for value in splited {
            values.append(Double(String(value))!)
        }
        
        return FirestoreData(date: time, values: values)
    }
    
    func makeToFirestoreData(_ data: [String: [String]]) throws -> [String: [FirestoreData]] {
        var result: [String : [FirestoreData]] = [:]
        let keys = self.getKeys(data)
        for key in keys {
            let array = data[key]!
            
            let parsed = try array.map{ value in
                try self.parseStringToData(stringValue: value)
            }
            result[key] = parsed
        }
        return result
    }
    
    private func getKeys(_ dict: [String: Any]) -> [String] {
        let keys = Array(dict.keys)
        return keys
    }
}
