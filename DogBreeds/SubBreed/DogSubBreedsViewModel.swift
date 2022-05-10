//
//  DogSubBreedsViewModel.swift
//  DogBreeds
//
//  Created by Yordan Poydovski on 9.05.22.
//

import Foundation
import UIKit

struct DogSubBreedModel {
    let subBreed: String
    var randomImageForSubBreed: LoadingImage = .notLoaded

    func getImage() -> UIImage? {
        //    Prefer to use exhaustive switch vs if case let
        //    to prevent errors when adding new cases
        switch randomImageForSubBreed {
        case .loaded(let image):
            return image
        case .loading, .notLoaded:
            return nil
        }
    }
}

final class DogSubBreedsViewModel {
    let breedName: String
    let webService: DogBreedsWebServiceProtocol

    private var searchInput: String = "" {
        didSet {
            filterData()
        }
    }

    private var data: [DogSubBreedModel] {
        didSet {
            filterData()
        }
    }

    var filteredData: [DogSubBreedModel] = [] {
        didSet {
            bindSubBreedsViewModelToController()
        }
    }

    var bindSubBreedsViewModelToController: (() -> Void) = {}
    var bindSubBreedsImageChangeToController: ((Int) -> Void) = { _ in }

    init(breedName: String,
         subBreeds: [String],
         webService: DogBreedsWebServiceProtocol) {
        self.breedName = breedName
        data = subBreeds.map {
            DogSubBreedModel(subBreed: $0,
                             randomImageForSubBreed: .notLoaded)
        }
        self.webService = webService
    }

    func searchDidChangeTo(_ search: String) {
        searchInput = search
    }

    private func filterData() {
        if searchInput.isEmpty {
            filteredData = data
        } else {
            filteredData = data.filter {
                $0.subBreed.lowercased().contains(searchInput.lowercased())
            }
        }
    }

    func getImages() {
        for index in data.indices {
            let subBreedName = data[index].subBreed

            webService.getRandomImageFor(breedName,
                                         subBreed: subBreedName,
                                         completion: { [weak self] result in
                                             let imageResult: UIImage?
                                             switch result {
                                             case .success(let image):
                                                 imageResult = image.resizedImage()
                                             case .failure:
                                                 imageResult = nil
                                             }

                                             self?.getRandomImageForBreedDidSucceed(subBreedName,
                                                                                    image: imageResult,
                                                                                    filteredIndex: index)
                                         })
        }
    }

    private func getRandomImageForBreedDidSucceed(_ subBreed: String,
                                                  image: UIImage?,
                                                  filteredIndex: Int) {
        let subBreedIndex = data.firstIndex(where: {
            $0.subBreed == subBreed
        }) ?? -1

        if subBreedIndex >= 0 && subBreedIndex < data.count {
            data[subBreedIndex].randomImageForSubBreed = .loaded(image)
        }
        bindSubBreedsImageChangeToController(filteredIndex)
    }
}
