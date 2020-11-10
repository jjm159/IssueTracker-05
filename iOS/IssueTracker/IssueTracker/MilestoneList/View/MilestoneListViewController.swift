import UIKit


class MilestoneListViewController: UIViewController {
    
    var didSendEventClosure: ((MilestoneListViewController.Event)-> Void)?
    lazy var dataLayout = makeDataLayout()
    var viewModel = MilestoneListViewModel()
    
    @IBOutlet weak var collectionView: UICollectionView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        navigationItem.rightBarButtonItem
            = UIBarButtonItem(
                image: UIImage(systemName: "plus"),
                style: .done,
                target: self, action: #selector(addMilestoneButtonTabbed))
        bind()
    }
    
    func bind() {
        viewModel.status.milestones.bindAndFire(applyAnapshot)
        viewModel.status.selectedMilestone.bind(editMilestone)
    }
    
    func configureCollectionView() {
        collectionView.collectionViewLayout = configureCollectionViewLayout()
        collectionView.delegate = self
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.attributedTitle = NSAttributedString(string: "새로고침")
        collectionView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc func refresh() {
        viewModel.action.refreshData()
        collectionView.refreshControl?.endRefreshing()
    }
    
    func editMilestone(with milestone: Milestone) { // 편집 모드
        let editVC = configureLabelEdiginVC()
        editVC.setupDefaultValue(with: milestone)
        present(editVC, animated: false)
    }
    
    @objc func addMilestoneButtonTabbed() { // 추가 모드
        let editVC = configureLabelEdiginVC()
        present(editVC, animated: false)
    }
    
    func configureLabelEdiginVC() -> MilestoneEditingViewController {
        let editVC: MilestoneEditingViewController
            = UIStoryboard(name: "MilestoneList", bundle: nil)
            .instantiateViewController(identifier: String(describing: MilestoneEditingViewController.self))
        editVC.modalPresentationStyle = .overCurrentContext
        editVC.delegate = self
        //viewModel.status.resultOfSaving.bind(editVC.resultOfSuccess(result:))
        return editVC
    }
    
    func applyAnapshot(sections: [Milestone]) {
        var snapshot = NSDiffableDataSourceSnapshot<[Milestone], Milestone>()
        snapshot.appendSections([sections])
        snapshot.appendItems(sections)
        dataLayout.apply(snapshot, animatingDifferences: true)
    }
    
    func configureCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 3, leading: 0, bottom: 0, trailing: 0)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func makeDataLayout() -> UICollectionViewDiffableDataSource<[Milestone],Milestone> {
        return UICollectionViewDiffableDataSource<[Milestone], Milestone>(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, milestone
                -> UICollectionViewCell? in
                guard let weakSelf = self else { return nil }
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MilestoneListViewCell", for: indexPath) as? MilestoneListViewCell else {
                    return nil
                }
                cell.setup(with: milestone)
                return cell
            })
    }

}

extension MilestoneListViewController: MilestoneEditingViewControllerDelegate {
    func MilestoneEditSaveButtonDidTab(title: String, description: String?, date: String, milestoneID: Int?) {
        
    }
    
    func MilestoneEditSaveButtonDidTab(title: String, description: String, date color: String, milestoneID labelID: String?) {
        
    }
}

extension MilestoneListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath)
                as? MilestoneListViewCell else { return }
//        guard let id = cell.milestoneID else { return }
//        guard let title = cell.milestoneTitle.title(for: .normal) else { return }
//        guard let desc = cell.descriptionLabel.text else { return }
//        guard let date = cell.dueDateLabel.text else { return }
        guard let milestone = cell.milestone else { return }
        viewModel.action.cellTouched(milestone)
    }
}

extension MilestoneListViewController {
    enum Event {
        case finished
    }
}


#if DEBUG

import SwiftUI

struct MilestoneListViewController_Preview: PreviewProvider {
    static var previews: some View {
        let vc = UIStoryboard(name: "MilestoneList", bundle: nil)
            .instantiateViewController(identifier: String(describing: MilestoneListViewController.self))
        return vc.view.liveView
    }
}

#endif
