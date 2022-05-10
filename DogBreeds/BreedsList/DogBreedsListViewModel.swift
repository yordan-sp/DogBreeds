//
//  DogBreedsListViewModel.swift
//  DogBreeds
//
//  Created by Yordan Poydovski on 7.05.22.
//

import Foundation
import UIKit

struct DogBreedsListModel {
    let breed: String
    let subBreeds: [String]
    var randomImageForBreed: LoadingImage = .notLoaded {
        didSet {
            bindBreedImageToController()
        }
    }

    var bindBreedImageToController: (() -> Void) = {}

    func getImage() -> UIImage? {
        //	Prefer to use exhaustive switch vs "if case let"
        //	to prevent errors when adding new cases
        switch randomImageForBreed {
        case .loaded(let image):
            return image
        case .loading, .notLoaded:
            return UIImage(named: "DefaultDogImage")?.resizedImage()
        }
    }
}

final class DogBreedsListViewModel {
    let webService: DogBreedsWebServiceProtocol

    private var searchInput: String = "" {
        didSet {
            filterData()
        }
    }

    private var data: [DogBreedsListModel] = [] {
        didSet {
            filterData()
        }
    }

    private(set) var filteredData: [DogBreedsListModel] = [] {
        didSet {
            
            if filteredData.count != oldValue.count {
                bindBreedsListToController()
            } else {
                let indicesWithDifferences = zip(filteredData, oldValue).enumerated().filter {
                    $1.0.breed != $1.1.breed
                }.map { $0.0 }

                if indicesWithDifferences.count > 0 {
                    bindBreedsListToController()
                }
            }
        }
    }

    var bindBreedsListToController: (() -> Void) = {}
    var bindBreedImageChangeToController: ((Int) -> Void) = { _ in }

    //	A dependency injection example
    //	that is commonly used but not always
    //	called with its name
    init(webService: DogBreedsWebServiceProtocol) {
        self.webService = webService
    }

    func loadBreeds() {
        webService.getBreedsList(completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }

            switch result {
            case .success(let response):
                strongSelf.data = strongSelf.mapResponseToViewModel(response: response)
            case .failure:
                strongSelf.data = []
            }

        })
    }

    func getBreedDataAt(_ index: Int) -> (breed: String, subBreedsCount: Int, image: UIImage?) {
        guard index < filteredData.count else {
            return ("", 0, nil)
        }
        return (filteredData[index].breed,
                filteredData[index].subBreeds.count,
                filteredData[index].getImage())
    }

    func getSelectedBreedDataAt(_ index: Int) -> (breed: String, subBreeds: [String])? {
        if index < data.count {
            return (data[index].breed, data[index].subBreeds)
        } else {
            return nil
        }
    }

    func searchDidChangeTo(_ search: String) {
        searchInput = search
    }

    private func filterData() {
        if searchInput.isEmpty {
            filteredData = data
        } else {
            filteredData = data.filter {
                $0.breed.lowercased().contains(searchInput.lowercased())
            }
        }
    }

    func willDisplayAt(_ index: Int) {
        guard let breedName = filteredData.get(at: index)?.breed,
              case .notLoaded = filteredData.get(at: index)?.randomImageForBreed else {
            return
        }

        webService.getRandomImageFor(breedName,
                                     completion: { [weak self] result in
                                         let imageResult: UIImage?
                                         switch result {
                                         case .success(let image):
                                             imageResult = image.resizedImage()
                                         case .failure:
                                             imageResult = nil
                                         }

                                         self?.getRandomImageForBreedDidSucceed(breedName,
                                                                                image: imageResult,
                                                                                filteredIndex: index)
                                     })
    }

    private func getRandomImageForBreedDidSucceed(_ breedName: String,
                                                  image: UIImage?,
                                                  filteredIndex: Int) {
        let breedIndex = data.firstIndex(where: {
            $0.breed == breedName
        }) ?? -1

        if breedIndex >= 0 && breedIndex < data.count {
            data[breedIndex].randomImageForBreed = .loaded(image)
        }

        bindBreedImageChangeToController(filteredIndex)
    }

    private func mapResponseToViewModel(response: DogBreedsListResponseData) -> [DogBreedsListModel] {
        let models = response.message.map {
            DogBreedsListModel(breed: $0.key,
                               subBreeds: $0.value.sorted(by: { $0 < $1 }),
                               randomImageForBreed: .notLoaded)
        }

        return models.sorted(by: { $0.breed < $1.breed })
    }
}
