//
//  Array+SafeGet.swift
//  DogBreeds
//
//  Created by Yordan Poydovski on 9.05.22.
//

import Foundation

public extension Array {
    /// Safely retrieve an element from an array
    ///
    /// - Parameter at: the expected index
    /// - Returns: the element at the index. Nil if indexOutOfBounds
    func get(at index: Int) -> Element? {
        guard index < count else { return nil }
        return self[index]
    }
}
