
import UIKit

class IssueListMainViewController: UIViewController {
    
    var didSendEventClosure: ((IssueListMainViewController.Event)-> Void)?
    
    @IBOutlet weak var searchContrainerView: UIView!
    @IBOutlet weak var resultContrainerView: UIView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var issueCreationButton: UIButton!
    
    var viewModel = IssueListViewModel()
    
    var searchViewController: SearchListViewController!
    var issueResultViewController: IssueResultViewController!
    
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchContrainerView.isHidden = true
        
        setupSearchListViewController()
        setupIssueResultViewController()
        
        navigationItem.leftBarButtonItem =
            UIBarButtonItem(title: "Filter", style: .done, target: self, action: #selector(filterButtonTabbed))
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editButtonTabbed))
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.topItem?.title = "이슈"
        self.tabBarController?.tabBar.isHidden = false
        self.issueCreationButton.bottomAnchor.constraint(equalTo: self.tabBarController!.tabBar.topAnchor).isActive = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    
    // MARK: Bind to ViewModel
    
    func bind() {
        viewModel.status.searchResultList
            .bindAndFire(issueResultViewController.applySnapshot(sections:))
        viewModel.status.searchResultTitleList
            .bind(searchViewController.applySnapshot(sections:))
        issueResultViewController.closeIssueButtonTabbed
            = viewModel.action.closeButtonTabbed
        issueResultViewController.deleteIssueButtonTabbed
            = viewModel.action.deleteButtonTabbed
        issueResultViewController.refreshData
            = viewModel.action.refreshData
        
    }
    
    
    // MARK: Action
    
    @IBAction func issueCreationButtonTabbed(_ sender: UIButton) {
        let creationVC:IssueCreationViewController = UIStoryboard(name: "IssueCreation", bundle: nil)
            .instantiateViewController(
                identifier: String(describing: IssueCreationViewController.self))
        self.present(creationVC, animated: true)
    }
    
    @objc func filterButtonTabbed() {
        let filterVC:IssueListFilterViewController = UIStoryboard(name: "IssueListFilter", bundle: nil)
            .instantiateViewController(
                identifier: String(describing: IssueListFilterViewController.self))
        self.present(filterVC, animated: true)
        
    }
    
    @objc func editButtonTabbed() {
        print("Edit")
    }
    
    
    // MARK: Configure Child View Controller
    
    func setupSearchListViewController() {
        searchViewController = UIStoryboard(name: "IssueList", bundle: nil)
            .instantiateViewController(identifier: String(describing: SearchListViewController.self))
        searchContrainerView.frame = searchContrainerView.bounds
        searchContrainerView.addSubview(searchViewController.view)
    }
    
    func setupIssueResultViewController() {
        issueResultViewController = UIStoryboard(name: "IssueList", bundle: nil)
            .instantiateViewController(identifier: String(describing: IssueResultViewController.self))
        issueResultViewController.view.frame = resultContrainerView.bounds
        resultContrainerView.addSubview(issueResultViewController.view)
        issueResultViewController.collectionview.delegate = self
    }
    
}


// MARK: UISearchBarDelegate Delegate

extension IssueListMainViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchContrainerView.isHidden = false
        resultContrainerView.isHidden = true
        issueCreationButton.isHidden = true
        navigationController?.isNavigationBarHidden = true
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.action.searchButtonClicked(searchBar.text ?? "")
        searchBar.searchTextField.text = ""
        searchBar.resignFirstResponder()
        searchContrainerView.isHidden = true
        resultContrainerView.isHidden = false
        issueCreationButton.isHidden = false
        
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.action.searchTextChanged(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.text = ""
        searchContrainerView.isHidden = true
        resultContrainerView.isHidden = false
        issueCreationButton.isHidden = false
        navigationController?.isNavigationBarHidden = false
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        viewModel.action.searchCancelButtonClicked()
    }
    
}


// MARK: UICollectionViewDelegate Delegate

extension IssueListMainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? IssueResultCellView else {
            return
        }
        let newVC = UIStoryboard(name: "IssueDetail", bundle: nil).instantiateViewController(identifier: String(describing: IssueDetailViewController.self)) as! IssueDetailViewController
        newVC.viewModel = IssueDetailViewModel(issueId: cell.iid ?? 0)
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.isNavigationBarHidden = false
        navigationController?.pushViewController(newVC, animated: true)
    }
}

extension IssueListMainViewController {
    enum Event {
        case finished
    }
}



// MARK: Preview

#if DEBUG

import SwiftUI

struct IssueListMainViewController_Preview: PreviewProvider {
    static var previews: some View {
        let vc = UIStoryboard(name: "IssueList", bundle: nil)
            .instantiateViewController(identifier: String(describing: IssueListMainViewController.self))
        return vc.view.liveView
    }
}

#endif
