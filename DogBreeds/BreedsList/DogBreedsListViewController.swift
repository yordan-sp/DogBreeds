//
//  DogBreedsListViewController.swift
//  DogBreeds
//
//  Created by Yordan Poydovski on 7.05.22.
//

import UIKit

final class DogBreedsListViewController: UIViewController {
    enum Constants {
        static let segueName = "ShowSubBreeds"
        static let cellHeight = 130.0
    }

    private let viewModel = DogBreedsListViewModel(webService: DogBreedsWebService())

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    private var selectedBreedIndex: Int?

    // MARK: - Controller methods

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self

        tableView.keyboardDismissMode = .onDrag
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        viewModel.bindBreedsListToController = {
            self.updateData()
        }

        viewModel.bindBreedImageChangeToController = { index in
            self.updateRow(index)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.loadBreeds()
    }

    private func updateData() {
        tableView.reloadData()
    }

    private func updateRow(_ row: Int) {
        let indexPath = IndexPath(row: row,
                                  section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segueName,
           let selectedBreedIndex = selectedBreedIndex,
           let info = viewModel.getSelectedBreedDataAt(selectedBreedIndex) {
            if let viewController = segue.destination as? DogSubBreedsViewController {
                viewController.viewModel = DogSubBreedsViewModel(breedName: info.breed,
                                                                 subBreeds: info.subBreeds,
                                                                 webService: DogBreedsWebService())
            }
        }
    }
}

// MARK: - UISearchBarDelegate

extension DogBreedsListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchDidChangeTo(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension DogBreedsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredData.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < viewModel.filteredData.count else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.image = viewModel.getBreedDataAt(indexPath.row).image

        let assembledText = viewModel.getBreedDataAt(indexPath.row).breed
            + " - "
            + "\(viewModel.getBreedDataAt(indexPath.row).subBreedsCount)"
        content.text = assembledText
        cell.contentConfiguration = content
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel.willDisplayAt(indexPath.row)
    }

    //	A coordinator pattern or router pattern
    //	could be applied for better navigation
    //	but due to limited task scope and time
    //	segues are used
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBreedIndex = indexPath.row
        let info = viewModel.getSelectedBreedDataAt(indexPath.row)

        if !(info?.subBreeds.isEmpty ?? true) {
            performSegue(withIdentifier: Constants.segueName,
                         sender: self)
        } else {
            let alert = UIAlertController(title: "Alert",
                                          message: "No sub-breeds available",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .default,
                                          handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}
