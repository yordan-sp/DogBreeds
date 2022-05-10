//
//  DogSubBreedsViewController.swift
//  DogBreeds
//
//  Created by Yordan Poydovski on 8.05.22.
//

import UIKit

final class DogSubBreedsViewController: UIViewController {
    enum Constants {
        static let cellID = "cell"
        static let cellHeight = 130.0
        static let cellImageSize = CGSize(width: 100, height: 100)
    }

    var viewModel: DogSubBreedsViewModel?
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel?.breedName

        tableView.keyboardDismissMode = .onDrag
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellID)

        viewModel?.bindSubBreedsViewModelToController = {
            self.updateData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel?.getImages()
    }

    private func updateData() {
        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate

extension DogSubBreedsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel?.searchDidChangeTo(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension DogSubBreedsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.filteredData.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let models = viewModel?.filteredData else {
            return UITableViewCell()
        }

        guard indexPath.row < models.count else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellID, for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.image = models[indexPath.row].getImage()
        content.imageProperties.maximumSize = Constants.cellImageSize
        content.text = models[indexPath.row].subBreed
        cell.contentConfiguration = content

        cell.selectionStyle = .none
        return cell
    }
}
