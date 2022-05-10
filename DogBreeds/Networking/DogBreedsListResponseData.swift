//
//  DogBreedsListResponseData.swift
//  DogBreeds
//
//  Created by Yordan Poydovski on 7.05.22.
//

struct DogBreedsListResponseData: Decodable {
    let message: [String: [String]]
    let status: String
}

struct DogBreedsRandomImageResponseData: Decodable {
    let message: String
    let status: String
}
