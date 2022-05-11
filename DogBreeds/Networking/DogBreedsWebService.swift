//
//  DogBreedsWebService.swift
//  DogBreeds
//
//  Created by Yordan Poydovski on 7.05.22.
//

import Alamofire

typealias DogBreedsListsCompletion = (Result<DogBreedsListResponseData, Error>) -> Void
typealias DogRandomImageForBreedCompletion = (Result<UIImage, Error>) -> Void

protocol DogBreedsWebServiceProtocol {
    func getBreedsList(completion: @escaping DogBreedsListsCompletion)
    func getRandomImageFor(_ breed: String,
                           completion: @escaping DogRandomImageForBreedCompletion)
    func getRandomImageFor(_ breed: String,
                           subBreed: String,
                           completion: @escaping DogRandomImageForBreedCompletion)
}

enum DogBreedsWebServiceError: Error {
    case generalError
}

final class DogBreedsWebService: DogBreedsWebServiceProtocol {
    private enum Constants {
        static let listURL = "https://dog.ceo/api/breeds/list/all"
        static let randomImageForBreedURL = "https://dog.ceo/api/breed/%@/images/random"
        static let randomImageForSubBreedURL = "https://dog.ceo/api/breed/%@/%@/images/random"
    }

    func getBreedsList(completion: @escaping DogBreedsListsCompletion) {
        //	The list with breeds and theirs sub-breeds is fetched
        //	So the sub-breeds are utilised from here
        //	and `https://dog.ceo/api/breed/%@/list` is not used for this task
        AF.request(Constants.listURL)
            .response { response in
                let jsonDecoder = JSONDecoder()
                if let value = response.value as? Data {
                    let data = try! jsonDecoder.decode(DogBreedsListResponseData.self, from: value)
                    completion(.success(data))
                }
            }
    }

    func getRandomImageFor(_ breed: String,
                           completion: @escaping DogRandomImageForBreedCompletion) {
        let url = String(format: Constants.randomImageForBreedURL, breed)
        AF.request(url)
            .response { response in
                let jsonDecoder = JSONDecoder()
                if let value = response.value as? Data {
                    let imageURLData = try! jsonDecoder.decode(DogBreedsRandomImageResponseData.self, from: value)

                    AF.request(imageURLData.message)
                        .response { response in
                            if let imageData = response.value as? Data,
                               let image = UIImage(data: imageData, scale: 1) {
                                completion(.success(image))
                            } else {
                                completion(.failure(DogBreedsWebServiceError.generalError))
                            }
                        }
                }
            }
    }

    func getRandomImageFor(_ breed: String,
                           subBreed: String,
                           completion: @escaping DogRandomImageForBreedCompletion) {
        let url = String(format: Constants.randomImageForSubBreedURL, breed, subBreed)
        AF.request(url)
            .response { response in
                let jsonDecoder = JSONDecoder()
                if let value = response.value as? Data {
                    let imageURLData = try! jsonDecoder.decode(DogBreedsRandomImageResponseData.self, from: value)

                    AF.request(imageURLData.message)
                        .response { response in
                            if let imageData = response.value as? Data,
                               let image = UIImage(data: imageData, scale: 1) {
                                completion(.success(image))
                            } else {
                                completion(.failure(DogBreedsWebServiceError.generalError))
                            }
                        }
                }
            }
    }
}
