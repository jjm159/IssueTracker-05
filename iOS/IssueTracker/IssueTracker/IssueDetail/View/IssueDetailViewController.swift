
import UIKit

class IssueDetailViewController: UIViewController {
    
    var viewModel: IssueDetailViewModel?
    lazy var dataLayout = makeDataLayout()
    var swipeUpView: IssueDetailEditingViewController!
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var issueTitle: UILabel!
    @IBOutlet weak var issueNumber: UILabel!
    @IBOutlet weak var isOpenView: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
    var isOpen = true  {// TODO: viewmodel에 바인딩 된 함수에서 바꿔준다.
        didSet {
            configureIsOpenView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        configureIsOpenView()
        collectionView.collectionViewLayout = createCompositionalList()
        configureContainerOfSwipeView()
        if let viewModel = viewModel {
            viewModel.status.model.bindAndFire(updateViews(model:))
            return
        }
        
        // TODO: 나중에 제거해야 한다. 
//        updateViews(model: IssueDetailModel.all())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureContainerOfSwipeView()
    }
    
    func updateViews(model: IssueDetailModel) {
        
        // 유저 이미지 - 아직은 없음
        
        issueTitle.text = model.title
        issueNumber.text = "#\(model.iid)"
        isOpen = model.isOpen
        
        // 댓글 목록 -> apply
        if let comments = model.comments {
            applySnapshot(sections: comments)
        } else {
            applySnapshot(sections: Comment.all())
        }
        
        swipeUpView.collectionView.reloadData()
        
        //swipeUpView update -> 담당자, 마일스톤, 레이블
    }
    
    func applySnapshot(sections: [Comment]) {
        var snapshot = NSDiffableDataSourceSnapshot<[Comment], Comment>()
        snapshot.appendSections([sections])
        snapshot.appendItems(sections)
        dataLayout.apply(snapshot, animatingDifferences: true)
    }
    
    func createCompositionalList() -> UICollectionViewLayout {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 10, leading: 0, bottom: 5, trailing: 0)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
                top: 5, leading: 5, bottom: 5, trailing: 5)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func makeDataLayout() -> UICollectionViewDiffableDataSource<[Comment], Comment> {
        UICollectionViewDiffableDataSource<[Comment], Comment>(
            collectionView: collectionView,
            cellProvider: { (collectionview, indexPath, comment) -> UICollectionViewCell? in
                let cell = collectionview.dequeueReusableCell(withReuseIdentifier: "IssueCommentCellView", for: indexPath) as? IssueCommentCellView
                cell?.setup(
                    user: comment.user.userId,
                    content: comment.content,
                    time: comment.createdAt)
                return cell
            })
    }
    
    func configureIsOpenView() {
        isOpenView.setImage(
            UIImage(systemName: "exclamationmark.circle"),
            for: .normal)
        let title = isOpen ? "open" : "closed"
        isOpenView.setTitle(title, for: .normal)
        isOpenView.backgroundColor = isOpen ? .systemGreen : .systemPink
        isOpenView.tintColor = isOpen ? .white : .white
        isOpenView.contentEdgeInsets = UIEdgeInsets(top: 1, left: 7, bottom: 1, right: 7)
    }
    
    func configureContainerOfSwipeView() {
        swipeUpView = UIStoryboard(name: "IssueDetailEditing", bundle: nil)
            .instantiateViewController(identifier: String(describing:IssueDetailEditingViewController.self))
        swipeUpView.viewModel = viewModel
        swipeUpView.delegate = self
        swipeUpView.view.frame = containerView.bounds
        containerView.addSubview(swipeUpView.view)
        swipeUpView.view.layer.cornerRadius = 15
        configureAnimation()
    }
    
    var swipeGesture: UISwipeGestureRecognizer!
    var oldY: CGFloat!
    var newY: CGFloat!
    
    func configureAnimation() {
        oldY = containerView.frame.origin.y
        newY = view.frame.height - containerView.frame.height
        swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(upperGesture))
        swipeGesture.direction = .up
        containerView.addGestureRecognizer(swipeGesture)
    }
    
    @objc func upperGesture(_ sender: Any) {
        UIView.transition(
            with: containerView,
            duration: 0.5,
            options: .curveEaseIn,
            animations: { [weak self] in
                guard let weakSelf = self else { return }
                let rect = CGRect(
                    x: weakSelf.containerView.frame.origin.x,
                    y: weakSelf.swipeGesture.direction == .up ?
                        weakSelf.newY : weakSelf.oldY,
                    width: weakSelf.containerView.frame.width,
                    height: weakSelf.containerView.frame.height)
                weakSelf.containerView.frame = rect
                weakSelf.swipeGesture.direction
                    = weakSelf.swipeGesture.direction == .up ? .down : .up
                weakSelf.swipeUpView.collectionView.isScrollEnabled.toggle()
            })
    }
    
    func configureNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "Edit", style: .done, target: nil, action: #selector(pushEditViewController))
    }
    
    @objc func pushEditViewController() {
        print("Edit")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // TODO: action과 configure를 구분
    
}

extension IssueDetailViewController: IssueDetailEditingViewControllerDelegate {
    func scrollUpButtonTabbed() {
        print("up")
        let topPoint = CGPoint(x: 0, y: 0)
        collectionView.setContentOffset(topPoint, animated: true)
    }
    
    func scrollDownButtonTabbed() {
        print("down")
        let bottomPoint = CGPoint(x: 0, y: collectionView.contentSize.height - collectionView.frame.height)
        collectionView.setContentOffset(bottomPoint, animated: true)
    }
    
    func addCommentButtonTabbed() {
        print("button")
        // TODO: 이슈 생성 화면을 보여준다.
    }

}



#if DEBUG

import SwiftUI

struct IssueDetailViewController_Preview: PreviewProvider {
    static var previews: some View {
        let vc = UIStoryboard(name: "IssueDetail", bundle: nil)
            .instantiateViewController(identifier: String(describing: IssueDetailViewController.self))
        return vc.view.liveView
    }
}

#endif
