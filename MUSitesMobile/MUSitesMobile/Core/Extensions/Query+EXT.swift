//
//  Query+EXT.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/27/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

extension Query {
    // using generics
    func getDocuments<T> (as type: T.Type) async throws -> [T] where T: Decodable {
        try await getDocumentsWithLastDocument(as: type).documents
    }
    
    func getDocumentsWithLastDocument<T> (as type: T.Type) async throws -> (documents: [T], lastDocument: DocumentSnapshot?) where T: Decodable {
        // we can get a collection of documents, BUT they will count against our fetching quota, so if it is a large collection, we should query first
        
        // fetch a snapshot of the collection from Firestore
        let snapshot = try await self.getDocuments()
        
        // map the documents in snapshot as an array of type T and return the array
        let documents = try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
        
        return (documents, snapshot.documents.last)
    }
    
    // count documents in a query
    func aggregateCount() async throws -> Int {
        // queries the server, only returns a single Int (snapshot)
        let snapshot = try await self.count.getAggregation(source: .server)
        // cast to an Int
        return Int(truncating: snapshot.count)
    }
    
    func addSnapshotListener<T>(as type: T.Type) -> (AnyPublisher<[T], Error>, ListenerRegistration) where T : Decodable {
        // create a publisher
        let publisher = PassthroughSubject<[T], Error>() // [UserBuilding] will be published back to this app
        // CurrentValueSubject is a publisher that will produce values over time and has a value at the current state
            // PassthroughSubject is a publisher that does not have a starting value and only publishes through the publisher
        
        // execute a Query snapshot listener, closure is async and will return at a later point in time
        let listener = self.addSnapshotListener { querySnapshot, error in
            // this closure will continuouslly execute over time for the rest of its lifespan, any time there is a change at this collection, this snapshot listener will execute
            // needs @escaping because the completion handler will be outliving the original call for addListenerForAllUserBuildings() function
            
            // get snapshot of all type T as documents fot a user
            guard let documents = querySnapshot?.documents else {
                print("No Documents")
                return
            }
            
            // decode the snapshot's documents into an array of type T
            let data: [T] = documents.compactMap({ try? $0.data(as: T.self) })
            
            // instead of calling completion handler, access the Publisher above and send an input [UserBuilding] into it
            publisher.send(data)
        }
        
        // return publisher back to app immediately, so the view can simply listen to the publisher
        return (publisher.eraseToAnyPublisher(), listener)
    }
}
