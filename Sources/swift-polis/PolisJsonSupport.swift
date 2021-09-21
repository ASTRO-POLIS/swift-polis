//
//  PolisJsonSupport.swift
//  
//
//  Created by Georg Tuparev on 19/09/2021.
//

import Foundation

@available(iOS 10, macOS 10.12, *)
public class PolisJSONDecoder: JSONDecoder {

    let dateFormatter = ISO8601DateFormatter()

    public override init() {
        super.init()

        dateDecodingStrategy = .custom{ (decoder) -> Date in
            let container  = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            let date       = self.dateFormatter.date(from: dateString)

            if let date = date { return date }
            else               { throw DecodingError.dataCorruptedError(in: container, debugDescription: "Date values must be ISO8601 formatted") }
        }
    }
}

@available(iOS 10, macOS 10.12, *)
public class PolisJSONEncoder: JSONEncoder {
    public override init() {
        super.init()

        self.dateEncodingStrategy = .iso8601
        self.outputFormatting     = .prettyPrinted
    }
}

