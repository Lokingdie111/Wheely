//
//  FirestoreManager.swift
//  Wheely
//
//  Created by 민현규 on 7/16/25.
//

import FirebaseFirestore

struct FirestoreData {
    let date: Date
    let values: [Double]
}

enum FirestoreError: Error {
    case internalError
    case failedToGetData
    case failedUnwrapData
    case firebase(code: FirestoreErrorCode.Code)
}

@MainActor
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
                
                guard let data = document.data() as? [String: [String]] else {
                    print("Failed to casting document data.")
                    continuation.resume(returning: nil)
                    return
                }
                
                let formatter = FirestoreFormater()
                let result = try? formatter.makeToFirestoreData(data)
                continuation.resume(returning: result)
            }
        }
        return result
    }
    
    public func get(_ name: String) async -> [FirestoreData]? {
        let result = await self.get()
        
        if let result = result {
            let value = result[name]
            return value
        } else {
            return nil
        }
    }
    /// Firestore에 데이터를 추가합니다.
    ///
    /// - Returns: 데이터 추가에 성공하면 true를 반환합니다.
    public func addData(_ name: String, data: FirestoreData) async -> Bool {
        guard var _data = await self.get(name) else {
            print("Failed to get datas")
            return false
        }
        
        for d in _data {
            if d.date == data.date {
                print("Failed to add datas, same date exist. data: \(d.date) given: \(data.date)")
                return false
            }
        }
        
        _data.append(data)
        
        let formatter = FirestoreFormater()
        
        let encoded = _data.map { value in
            formatter.makeDataToString(value)
        }
        
        do {
            try await db.collection(collection).document(uid).setData(["\(name)": encoded], merge: true)
            return true
        } catch {
            print("Failed to push datas")
            return false
        }
    }
    public func updateData(_ name: String, data: FirestoreData) async -> Bool {
        guard var datas = await self.get(name) else {
            print("Failed to get datas.")
            return false
        }
        
        for index in 0..<datas.count {
            if datas[index].date == data.date {
                datas[index] = data
                break
            }
        }
        
        let f = FirestoreFormater()
        
        let encoded = datas.map { value in
            f.makeDataToString(value)
        }
        
        do {
            try await db.collection(collection).document(uid).setData(["\(name)": encoded], merge: true)
            return true
        } catch {
            print("Failed to push datas")
            return false
        }       
    }
    /// Firestore에 있는 데이터를 삭제합니다.
    ///
    /// > 만약 찾는 날짜의 데이터가 존재하지 않으면 아무 행동도 하지 않고 True를 반환합니다.
    ///
    /// - Returns: 데이터 삭제에 성공하면 true를 반환합니다.
    ///
    /// - Parameters:
    ///     - name: 필드 이름.
    ///     - date: 삭제할 데이터의 날짜.
    public func deleteData(_ name: String, date: Date) async -> Bool {
        guard var datas = await self.get(name) else {
            print("Failed to get datas")
            return false
        }
        datas.removeAll { $0.date == date }
        let f = FirestoreFormater()
        
        let encoded = datas.map { value in
            f.makeDataToString(value)
        }
        
        do {
            try await db.collection(collection).document(uid).setData(["\(name)": encoded], merge: true)
            return true
        } catch {
            print("Failed to push datas")
            return false
        }
    }
    
    public func makeField(_ name: String, checkExist: Bool = false) async {
        var exist: Bool
        
        if checkExist {
            let result = await self.checkFieldExist(name: name)
            if result == true {
                exist = true
            } else {
                exist = false
            }
            
        } else {
            exist = false
        }
        
        if !exist {
            do {
                print("MAKE FIELD")
                try await db.collection(collection).document(uid).setData(["\(name)": []], merge: true)
                return
            } catch {
                print("Failed to make field.")
                return
            }
        } else {
            print("Failed to make field, field name is already exist")
        }
    }
    
    public func makeDocument(checkExist: Bool = false) async {
        var exist: Bool
        if checkExist {
            let result = await self.checkDocumentExist(uid)
            if result == true {
                exist = true
            } else {
                exist = false
            }
        } else {
            exist = false
        }
        
        if !exist {
            do {
                try await db.collection(collection).document(uid).setData([:])
                print("Successfully make Document name \(uid)")
            } catch {
                print("Failed to make Document")
            }
            return
        } else {
            print("Document name \(uid) is already exist")
            return
        }
    }
    
    /// Dictonary안의 키들을 모두 가져옵니다.
    private func getKeys(_ dict: [String : Any]) -> [String] {
        let keys = Array(dict.keys)
        return keys
    }
    
    private func checkDocumentExist(_ target: String) async -> Bool? {
        
        let result: Bool? = await withCheckedContinuation { continuation in
            db.collection(collection).getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    continuation.resume(returning: nil)
                    return
                }
                
                for d in documents {
                    if d.documentID == target {
                        continuation.resume(returning: true)
                        return
                    }
                }
                
                continuation.resume(returning: false)
            }
        }
        
        return result
    }
    public func checkFieldExist(name: String) async -> Bool? {
        guard let datas = await self.get() else {
            print("Failed to fecth document datas")
            return nil
        }
        
        let result = datas[name]
        
        if result == nil {
            return false
        } else {
            return true
        }
    }
    
    init(uid: String) {
        self.uid = uid
    }
}
