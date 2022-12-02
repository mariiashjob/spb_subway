//
//  Extensions+Extensions.swift
//  spb_subway
//
//  Created by m.shirokova on 25.11.2022.
//

extension String {
    
    func removeSpaces() -> String {
        return self.replacingOccurrences(of: " ", with: "").lowercased()
    }
}
