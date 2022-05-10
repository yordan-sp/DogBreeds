//
//  DogSubBreedsViewModelTests.swift
//  DogBreedsTests
//
//  Created by Yordan Poydovski on 9.05.22.
//

@testable import DogBreeds
import XCTest

final class DogSubBreedsViewModelTests: XCTestCase {
    private enum Constants {
        static let breed = "Breed"
        static let subBreeds = ["SubBreed"]
    }

    private var breed: String!
    private var subBreeds: [String]!
    private var webService: MockWebService!
    private lazy var viewModel = DogSubBreedsViewModel(breedName: breed,
                                                       subBreeds: subBreeds,
                                                       webService: webService)

    override func setUp() {
        breed = Constants.breed
        subBreeds = Constants.subBreeds
        webService = MockWebService()
    }

    func testGetImagesSuccess() {
        var bindSubBreedsViewModelToControllerCallCount = 0

        webService.resultForGetBreedsList = .success(.makeStub())
        viewModel.bindSubBreedsViewModelToController = {
            bindSubBreedsViewModelToControllerCallCount += 1
        }

        viewModel.getImages()

        XCTAssertEqual(bindSubBreedsViewModelToControllerCallCount, 1)
        XCTAssertEqual(viewModel.filteredData.count, 1)
        XCTAssertEqual(webService.getBreedsListCallCount, 1)
    }

    // MARK: - Mocks

    private final class MockWebService: DogBreedsWebServiceProtocol {
        private(set) var getBreedsListCallCount = 0
        var resultForGetBreedsList: (Result<DogBreedsListResponseData, Error>)?
        func getBreedsList(completion: @escaping DogBreedsListsCompletion) {
            getBreedsListCallCount += 1
            if let result = resultForGetBreedsList {
                completion(result)
            }
        }

        private(set) var getRandomImageForBreedCallCount = 0
        var getRandomImageForBreedReceived: String?
        var resultForRandomImage: (Result<UIImage, Error>)?
        func getRandomImageFor(_ breed: String, completion: @escaping DogRandomImageForBreedCompletion) {
            getRandomImageForBreedCallCount += 1
            getRandomImageForBreedReceived = breed
            if let result = resultForRandomImage {
                completion(result)
            }
        }

        private(set) var getRandomImageForBreedAndSubBreedCallCount = 0
        var getRandomImageForBreedAndSubBreedHandler: ((String, String) -> Void)?
        func getRandomImageFor(_ breed: String, subBreed: String, completion: @escaping DogRandomImageForBreedCompletion) {
            getRandomImageForBreedAndSubBreedCallCount += 1
            getRandomImageForBreedAndSubBreedHandler?(breed, subBreed)
        }
    }
}

private extension DogBreedsListResponseData {
    static func makeStub(message: [String: [String]] = ["Breed": ["SomeSubBreed"]]) -> DogBreedsListResponseData {
        DogBreedsListResponseData(message: message,
                                  status: "success")
    }
}
