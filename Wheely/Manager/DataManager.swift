//
//  FirestoreManager.swift
//  Wheely
//
//  Created by 민현규 on 7/11/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
/// Wheely의 사용자 데이터를 관리합니다.
///
/// ## Firestore
/// 기본적으로 Firestore에 데이터를 저장하여 사용합니다.
///
/// ## Cache
/// Firestore에 너무 빈번한 요청을 방지하기 위해 한번 요청한 데이터를 재사용합니다.
///
/// ## 동기화
/// 처음 DataManager가 초기화되면 Firestore로 요청을 보내여 데이터를 모조리 가져옵니다.
///
/// - 데이터 읽기
///     - 데이터를 읽을때에는 캐시먼저 확인후 없으면 Firestore를 확인합니다.
/// - 데이터 쓰기
///     - Firestore에 먼저 쓴 후 성공시 캐시에도 작성합니다.
///
/// > Firestore가 Cache 보다 데이터가 항상 최신이거나 같습니다.
@MainActor
class DataManager {
    let firestoreManager: FirestoreManager
    let cacheManager: CacheManager
    
    /// 사용자 uid안의 모든 내용을 가져옵니다.
    public func get() async -> [String: [FirestoreData]]? {
        let cacheResult = cacheManager.cache
        
        if cacheResult.isEmpty {
            log("Cache empty!")
            guard let data = await firestoreManager.get() else {
                log("Failed to get data from firestore")
                return nil
            }
            log("Successfully get data from firestore")
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
                log("No name exist. Finding in firestore...")
                guard let fetch = await firestoreManager.get(name) else {
                    log("Failed to get data from firestore.")
                    return nil
                }
                
                cacheManager.cache[name] = fetch
                
                return fetch
            }
        } else {
            log("Failed to get data from firestore")
            return nil
        }
    }
    
    /// 데이터를 저장합니다.
    ///
    /// > 필드가 이미 생성되어있어야 합니다.
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
                log("Failed to add data to cache...")
            }
        } else {
            log("Failed to add data to firestore")
        }
    }
    public func deleteData(_ name: String, date: Date) async {
        let result = await firestoreManager.deleteData(name, date: date)
        if result {
            do {
                try cacheManager.deleteData(name, date: date)
            } catch {
                log("Failed to delete data from cache...")
            }
        } else {
            log("Failed to delete data in firestore.")
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
                log("Failed to update data in cache...")
            }
        } else {
            log("Failed to update data in firestore.")
        }
    }
    /// 필드 생성
    public func makeField(_ name: String) async {
        let result = await firestoreManager.makeField(name, checkExist: true)
        if result == false {
            log("Failed to make field in firestore.")
            return
        }
        do {
            try cacheManager.makeField(name)
        } catch {
            log("Field already exist in cache...")
        }
    }
    public func removeField(_ name: String) async {
        let result = await firestoreManager.removeField(name)
        if result {
            try? cacheManager.deleteField(name)
        } else {
            log("Failed to remove field in firestore.")
        }
    }
    
    public func updateFieldName(_ name: String, _ to: String) async {
        
        guard let value = self.cacheManager.cache[name] else {
            log("Name \"\(name)\" field not found in cache...")
            return
        }
        
        if self.cacheManager.cache[to] != nil {
            log("Name \"\(to)\" field already exist in cache...")
            return
        }
        
        let success = await self.firestoreManager.updateFieldName(name, to)
        if success {
            do {
                try self.cacheManager.upadateFieldName(name, to)
            } catch {
                log("Failed to update field name in cache...")
            }
        } else {
            log("Something wrong...")
        }
    }
    
    /// 도큐먼트 생성
    public func makeDocument() async {
        let result = await self.firestoreManager.makeDocument(checkExist: true)
        if result != true {
            log("Failed to make document in firestore.")
        }
    }
    /// 캐시가 비어있는지 체크하고 만약 비어있으면 채우기를 시도합니다.
    ///
    /// > 반환값이 True이면 일반적으로 이후 작업을 수행해도 좋다는 뜻입니다.
    ///
    /// - Returns: 데이터를 불러와 캐시에 저장하는것에 성공했으면 True, 그렇지 않으면 false를 반환합니다.
    private func emptySequence() async -> Bool{
        if cacheManager.cache.isEmpty {
            log("Cache is empty. Trying to get data from firestore...")
            guard let data = await firestoreManager.get() else {
                log("Failed to get data from firestore")
                return false
            }
            log("Successfully get data from firestore!")
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
            log("Failed to get data from firestore")
            cacheManager = CacheManager(cache: [:])
        }
        let dataManager = DataManager(firestoreManager: firestoreManager, cacheManager: cacheManager)
        await dataManager.makeDocument()
        return dataManager
    }
    
    private func log(_ msg: String) {
        print("[DataManager] \(msg)")
    }
    private static func log(_ msg: String) {
         print("[DataManager] \(msg)")       
    }
    
    private init(firestoreManager: FirestoreManager, cacheManager: CacheManager) {
        self.firestoreManager = firestoreManager
        self.cacheManager = cacheManager
    }
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
