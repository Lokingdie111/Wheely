//
//  FirestoreManager.swift
//  Wheely
//
//  Created by 민현규 on 7/11/25.
//

import Foundation
import FirebaseFirestore

@MainActor
class DataManager {
    let firestoreManager: FirestoreManager
    let cacheManager: CacheManager
    
    /// 사용자 uid안의 모든 내용을 가져옵니다.
    public func get() async -> [String: [FirestoreData]]? {
        let cacheResult = cacheManager.cache
        
        if cacheResult.isEmpty {
            print("[DataManager] Cache empty!")
            guard let data = await firestoreManager.get() else {
                print("Failed to get data from firestore")
                return nil
            }
            print("[DataManager] Successfully get data from firestore")
            cacheManager.cache = data
            return data
        } else{
            return cacheManager.cache
        }
    }
    
    /// 특정 필드안의 데이터를 가져옵니다.
    ///
    /// ## 실행과정
    /// 1. 캐시가 비어있는지 확인한후 비어있으면 채우기를 시도합니다.
    /// 2. 캐시안에 주어진 이름이 있는지 확인한후 없으면 Firestore에서 가져오는것을 시도합니다.
    /// 3. 그후 데이터가 있으면 캐시를 업데이트한후 값을 반환합니다.
    ///
    /// *중간에 어떠한 문제가 발생하면 nil을 반환합니다.*
    ///
    /// - Parameters:
    ///     - name: 필드 이름
    /// - Returns: 만약 데이터를 가져오는것에 실패하면 nil을 반환합니다.
    public func get(_ name: String) async -> [FirestoreData]? {
        if await emptySequence() {
            do {
                let result = try cacheManager.getAllData(name)
                return result
            } catch {
                print("[DataManager] No name exist. Finding in firestore...")
                guard let fetch = await firestoreManager.get(name) else {
                    print("[DataManager] Failed to get data from firestore.")
                    return nil
                }
                
                cacheManager.cache[name] = fetch
                
                return fetch
            }
        } else {
            print("[DataManager] Failed to get data from firestore")
            return nil
        }
    }
    
    /// 데이터를 저장합니다.
    ///
    /// ## 실행순서
    /// 1. Firestore에 먼저 데이터를 추가합니다.
    /// 2. 만약 성공했으면 진행, 그렇지 않으면 중단합니다.
    /// 3. 캐시에 추가합니다.
    public func addData(_ name: String, data: FirestoreData) async {
        let result = await firestoreManager.addData(name, data: data)

        if result {
            do {
                try cacheManager.addData(name, data: data)
            } catch {
                print("[DataManager] Failed to add data to cache...")
            }
        } else {
            print("[DataManager] Failed to add data to firestore")
        }
    }
    public func deleteData(_ name: String, date: Date) async {
        let result = await firestoreManager.deleteData(name, date: date)
        if result {
            do {
                try cacheManager.deleteData(name, date: date)
            } catch {
                print("[DataManager] Failed to delete data from cache...")
            }
        } else {
            print("[DataManager] Failed to delete data in firestore.")
        }
    }
    
    /// 데이터 배열에서 한 데이터를 수정합니다.
    ///
    /// - Parameters:
    ///     - name: 필드 이름.
    ///     - data: 바꿀 데이터.
    public func updateData(_ name: String, data: FirestoreData) async {
        let result = await firestoreManager.updateData(name, data: data)
        if result {
            do {
                try cacheManager.updateData(name, data: data)
            } catch {
                print("[DataManager] Failed to update data in cache...")
            }
        } else {
            print("[DataManager] Failed to update data in firestore.")
        }
    }
    
    /// 캐시가 비어있는지 체크하고 만약 비어있으면 채우기를 시도합니다.
    ///
    /// > 반환값이 True이면 일반적으로 이후 작업을 수행해도 좋다는 뜻입니다.
    ///
    /// - Returns: 데이터를 불러와 캐시에 저장하는것에 성공했으면 True, 그렇지 않으면 false를 반환합니다.
    private func emptySequence() async -> Bool{
        if cacheManager.cache.isEmpty {
            print("[DataManager] Cache is empty. Trying to get data from firestore...")
            guard let data = await firestoreManager.get() else {
                print("[DataManager] Failed to get data from firestore")
                return false
            }
            print("[DataManager] Successfully get data from firestore!")
            cacheManager.cache = data
            return true
        } else {
            return true
        }
    }
    
    /// 이 메서드로 DataManager를 초기화합니다.
    public static func create(uid: String) async -> DataManager {
        let firestoreManager = FirestoreManager(uid: uid)
        let cacheManager: CacheManager
        let data = await firestoreManager.get()
        if let data = data {
            cacheManager = CacheManager(cache: data)
        } else {
            print("[DataManager] Failed to get data from firestore")
            cacheManager = CacheManager(cache: [:])
        }
        return DataManager(firestoreManager: firestoreManager, cacheManager: cacheManager)
    }
    
    private init(firestoreManager: FirestoreManager, cacheManager: CacheManager) {
        self.firestoreManager = firestoreManager
        self.cacheManager = cacheManager
    }
}

// 일단 에러 처리는 나중에 하자.
// uid -> [Name : [FirestoreData]]







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
    func makeToString(_ data: [String: [FirestoreData]]) -> [String : [String]] {
        var result: [String : [String]] = [:]
        let keys = self.getKeys(data)
        
        for key in keys {
            let array = data[key]!
            
            let parsed = array.map{ value in
                self.makeDataToString(value)
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
