//
//  PrinterManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/24/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Printer: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String?
    let type: String?
    let siteId: String?
    let section: String?
    
    // create Site manually
    init(
        id: String,
        name: String? = nil,
        type: String? = nil,
        siteId: String? = nil,
        section: String? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.siteId = siteId
        self.section = section
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case type = "type"
        case siteId = "computing_site"
        case section = "section"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.siteId = try container.decodeIfPresent(String.self, forKey: .siteId)
        self.section = try container.decodeIfPresent(String.self, forKey: .section)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.type, forKey: .type)
        try container.encodeIfPresent(self.siteId, forKey: .siteId)
        try container.encodeIfPresent(self.section, forKey: .section)
    }
    
    static func == (lhs:Printer, rhs: Printer) -> Bool {
        // if two printers have the same ID, we're going to say they're equal to eachother
        return lhs.id == rhs.id
    }
}

final class PrinterManager {
    // create singleton of manager
    static let shared = PrinterManager()
    private init() { }
    
    // get the collection as CollectionReference
    private let printersCollection: CollectionReference = Firestore.firestore().collection("printers")
    
    // get Firestore document as DocumentReference
    private func printerDocument(printerId: String) -> DocumentReference {
        printersCollection.document(printerId)
    }
    
    // create Firestore encoder
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        return encoder
    }()
    
    // create Firestore decoder
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        return decoder
    }()
    
    // get a printer from Firestore as Printer struct
    func getPrinter(printerId: String) async throws -> Printer {
        try await printerDocument(printerId: printerId).getDocument(as: Printer.self)
    }
    
    // create a new printer in Firestore from struct
    func createPrinter(printer: Printer) async throws {
        // connect to Firestore and create a new document from codable struct
        try printerDocument(printerId: printer.id).setData(from: printer, merge: false)
    }
    
    // fetch printer collection onto local device
    private func getAllPrintersQuery() -> Query {
        printersCollection
    }
    
    // get printers filtered by site
    private func getPrintersBySiteQuery(siteId: String) -> Query {
        printersCollection
            .whereField(Printer.CodingKeys.siteId.rawValue, isEqualTo: siteId)
    }
    
    // get printers sorted by Name
    private func getAllPrintersSortedByNameQuery(descending: Bool) -> Query {
        printersCollection
            .order(by: Printer.CodingKeys.name.rawValue, descending: descending)
    }
    
    // get buildings filtered by site & sorted by name
    private func getAllPrintersBySiteAndNameQuery(siteId: String, descending: Bool) -> Query {
        // "The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/sitesmobile-4970/firestore/indexes?create_composite=ClFwcm9qZWN0cy9zaXRlc21vYmlsZS00OTcwL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9wcmludGVycy9pbmRleGVzL18QARoSCg5jb21wdXRpbmdfc2l0ZRABGggKBG5hbWUQARoMCghfX25hbWVfXxAB
        printersCollection
            // filter by site
            .whereField(Printer.CodingKeys.siteId.rawValue, isEqualTo: siteId)
            // sort by name
            .order(by: Printer.CodingKeys.name.rawValue, descending: descending)
    }
    
    // get printers by name
    func getAllPrinters(descending: Bool?, siteId: String?) async throws -> [Printer] {
        var query: Query = getAllPrintersQuery()
        
        // if given a Site and nameSort
        if let descending, let siteId {
            // filter and sort collection
            query = getAllPrintersBySiteAndNameQuery(siteId: siteId, descending: descending)
        // if given sort
        } else if let descending {
            // sort whole collection
            query = getAllPrintersSortedByNameQuery(descending: descending)
        // if given filter
        } else if let siteId {
            // filter whole collection
            query = getPrintersBySiteQuery(siteId: siteId)
        }
        
        print("Trying to query printers collection.")
        return try await query
            .getDocuments(as: Printer.self) // query Printers collection
    }
    
    // get count of all printers
    // we can use this to determine if we need to use pagination
    func allPrintersCount() async throws -> Int {
        try await printersCollection.aggregateCount()
    }
    
    func updatePrinters(_ printers: [Printer]) async throws {
        // Create a new batched write operation
        let batch = Firestore.firestore().batch()
        
        // Iterate over the printers array and update each document in the batch
        for printer in printers {
            // Get the reference to the document
            let documentRef = printerDocument(printerId: printer.id)
            
            // Encode the updated supplyCount object
            guard let data = try? encoder.encode(printer) else {
                // Handle encoding error
                throw PrinterManagerError.encodingError
            }
            
            // Set the data for the document in the batch
            batch.setData(data, forDocument: documentRef)
        }
        
        // Commit the batched write operation
        try await batch.commit()
    }
}

// Errors
enum PrinterManagerError: Error {
    case noPrinterId
    case encodingError
}
