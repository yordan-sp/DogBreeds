//
//  DogBreedsListViewModelTests.swift
//  DogBreedsTests
//
//  Created by Yordan Poydovski on 9.05.22.
//

@testable import DogBreeds
import XCTest

final class DogBreedsListViewModelTests: XCTestCase {
    private var webService: MockWebService!
    private lazy var viewModel = DogBreedsListViewModel(webService: webService)

    override func setUp() {
        webService = MockWebService()
    }

    func testLoadBreedsSuccess() {
        var bindBreedsListToControllerCallCount = 0

        webService.resultForGetBreedsList = .success(.makeStub())
        viewModel.bindBreedsListToController = {
            bindBreedsListToControllerCallCount += 1
        }

        viewModel.loadBreeds()

        XCTAssertEqual(bindBreedsListToControllerCallCount, 1)
        XCTAssertEqual(viewModel.filteredData.count, 1)
        XCTAssertEqual(webService.getBreedsListCallCount, 1)
    }

    func testLoadBreedsFailure() {
        var bindBreedsListToControllerCallCount = 0

        webService.resultForGetBreedsList = .failure(DogBreedsWebServiceError.generalError)
        viewModel.bindBreedsListToController = {
            bindBreedsListToControllerCallCount += 1
        }

        viewModel.loadBreeds()

        XCTAssertEqual(bindBreedsListToControllerCallCount, 0)
        XCTAssertEqual(viewModel.filteredData.count, 0)
        XCTAssertEqual(webService.getBreedsListCallCount, 1)
    }

    func testGetBreedDataAt() {
        var bindBreedsListToControllerCallCount = 0

        webService.resultForGetBreedsList = .success(.makeStub())
        viewModel.bindBreedsListToController = {
            bindBreedsListToControllerCallCount += 1
        }

        viewModel.loadBreeds()

        XCTAssertEqual(bindBreedsListToControllerCallCount, 1)
        XCTAssertEqual(viewModel.filteredData.count, 1)
        XCTAssertEqual(webService.getBreedsListCallCount, 1)

        let result = viewModel.getBreedDataAt(0)

        XCTAssertEqual(result.breed, "Breed")
        XCTAssertEqual(result.subBreedsCount, 1)
        XCTAssertEqual(result.image?.pngData(), UIImage(named: "DefaultDogImage")?.resizedImage().pngData())
    }

    func testGetSelectedBreedDataAt() {
        var bindBreedsListToControllerCallCount = 0

        webService.resultForGetBreedsList = .success(.makeStub())
        viewModel.bindBreedsListToController = {
            bindBreedsListToControllerCallCount += 1
        }

        viewModel.loadBreeds()

        XCTAssertEqual(bindBreedsListToControllerCallCount, 1)
        XCTAssertEqual(viewModel.filteredData.count, 1)
        XCTAssertEqual(webService.getBreedsListCallCount, 1)

        let result = viewModel.getSelectedBreedDataAt(0)

        XCTAssertEqual(result?.breed, "Breed")
        XCTAssertEqual(result?.subBreeds.first, "SomeSubBreed")
    }

    func testSearchDidChangeTo() {
        var bindBreedsListToControllerCallCount = 0

        webService.resultForGetBreedsList = .success(.makeStub(message: ["Breed": ["SomeSubBreed"],
                                                                         "Pinsher": ["Mini"]]))
        viewModel.bindBreedsListToController = {
            bindBreedsListToControllerCallCount += 1
        }

        viewModel.loadBreeds()

        XCTAssertEqual(bindBreedsListToControllerCallCount, 1)
        XCTAssertEqual(viewModel.filteredData.count, 2)
        XCTAssertEqual(webService.getBreedsListCallCount, 1)

        let input = "bre"
        viewModel.searchDidChangeTo(input)

        XCTAssertEqual(bindBreedsListToControllerCallCount, 2)
        XCTAssertEqual(viewModel.filteredData.count, 1)
        XCTAssertEqual(webService.getBreedsListCallCount, 1)
    }

    func testWillDisplayAtSuccess() {
        var bindBreedsListToControllerCallCount = 0
        var bindBreedImageChangeToControllerCallCount = 0

        webService.resultForGetBreedsList = .success(.makeStub())
        webService.resultForRandomImage = .success(UIImage(named: "DefaultDogImage")!)

        viewModel.bindBreedsListToController = {
            bindBreedsListToControllerCallCount += 1
        }

        viewModel.bindBreedImageChangeToController = { _ in
            bindBreedImageChangeToControllerCallCount += 1
        }

        viewModel.loadBreeds()

        XCTAssertEqual(bindBreedsListToControllerCallCount, 1)
        XCTAssertEqual(bindBreedImageChangeToControllerCallCount, 0)
        XCTAssertEqual(viewModel.filteredData.count, 1)
        XCTAssertEqual(webService.getBreedsListCallCount, 1)

        viewModel.willDisplayAt(0)

        XCTAssertEqual(bindBreedsListToControllerCallCount, 1)
        XCTAssertEqual(bindBreedImageChangeToControllerCallCount, 1)
        XCTAssertEqual(viewModel.filteredData.count, 1)
        XCTAssertEqual(webService.getBreedsListCallCount, 1)
    }

    func testWillDisplayAtFailure() {
        var bindBreedsListToControllerCallCount = 0
        var bindBreedImageChangeToControllerCallCount = 0

        webService.resultForGetBreedsList = .success(.makeStub())
        webService.resultForRandomImage = .failure(DogBreedsWebServiceError.generalError)

        viewModel.bindBreedsListToController = {
            bindBreedsListToControllerCallCount += 1
        }

        viewModel.bindBreedImageChangeToController = { _ in
            bindBreedImageChangeToControllerCallCount += 1
        }

        viewModel.loadBreeds()

        XCTAssertEqual(bindBreedsListToControllerCallCount, 1)
        XCTAssertEqual(bindBreedImageChangeToControllerCallCount, 0)
        XCTAssertEqual(viewModel.filteredData.count, 1)
        XCTAssertEqual(webService.getBreedsListCallCount, 1)

        viewModel.willDisplayAt(0)

        XCTAssertEqual(bindBreedsListToControllerCallCount, 1)
        XCTAssertEqual(bindBreedImageChangeToControllerCallCount, 1)
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
