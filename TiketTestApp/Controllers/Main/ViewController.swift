//
//  ViewController.swift
//  TiketTestApp
//
//  Created by Dedy Yuristiawan on 18/04/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit
import SVPullToRefresh
import SkeletonView

class ViewController: UIViewController {
    
    lazy var refreshControls: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.systemGray
        
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControls: UIRefreshControl) {
        self.refresh()
    }
    
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.register(UINib(nibName: "ItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ItemCollectionViewCell")
            collectionView.delaysContentTouches = false
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.alwaysBounceVertical = true
            collectionView.addSubview(refreshControls)
            collectionView.isSkeletonable = true
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.minimumLineSpacing = 0
                layout.minimumInteritemSpacing = 0
                layout.sectionInset = .init(top: 20, left: 20, bottom: 0, right: 20)
            }
        }
    }
    @IBOutlet weak var collectionViewMenu: UICollectionView!{
        didSet{
            collectionViewMenu.register(UINib(nibName: "MenuCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MenuCollectionViewCell")
            collectionViewMenu.register(UINib(nibName: "ItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ItemCollectionViewCell")
            collectionViewMenu.delaysContentTouches = false
            collectionViewMenu.delegate = self
            collectionViewMenu.dataSource = self
            collectionViewMenu.showsVerticalScrollIndicator = true
            collectionViewMenu.alwaysBounceVertical = true
            collectionViewMenu.isSkeletonable = true
            if let layout = collectionViewMenu.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.minimumLineSpacing = 20
                layout.minimumInteritemSpacing = 0
                layout.sectionInset = .init(top: 20, left: 0, bottom: 0, right: 0)
            }
        }
    }
    
    var itemInteractor: ItemInteractor? = ItemInteractor(params: ["device" : "ios", "query" : "office"])
    var marginCenter = 20
    var witdhCollectionViewMenu = 100
    lazy var gradient = SkeletonGradient(baseColor: UIColor.gray)
    var selectedRole = "All"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "All"
        
        self.refreshControls.beginRefreshing()
        self.collectionView.setContentOffset(CGPoint(x: 0, y: -refreshControls.frame.size.height), animated: true)
        self.collectionView.prepareSkeleton(completion: { done in
            self.collectionView.showAnimatedGradientSkeleton(usingGradient: self.gradient, transition: .crossDissolve(0.25))
        })
        self.collectionViewMenu.prepareSkeleton(completion: { done in
            self.collectionViewMenu.showAnimatedGradientSkeleton(usingGradient: self.gradient, transition: .crossDissolve(0.25))
        })
        self.refresh()
    }
    
    func refresh(){
        self.collectionView.hideSkeleton()
        self.collectionViewMenu.hideSkeleton()
        collectionView.showAnimatedGradientSkeleton(usingGradient: self.gradient, transition: .crossDissolve(0.25))
        collectionViewMenu.showAnimatedGradientSkeleton(usingGradient: self.gradient, transition: .crossDissolve(0.25))
        self.itemInteractor?.refresh(success: { () in
            self.collectionView.hideSkeleton(transition: .crossDissolve(0.25))
            self.collectionViewMenu.hideSkeleton(transition: .crossDissolve(0.25))
            self.refreshControls.endRefreshing()
            self.collectionView.reloadData()
            self.collectionViewMenu.reloadData()
            let indexPath = self.collectionView.indexPathsForSelectedItems?.last ?? IndexPath(item: 0, section: 0)
            self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
        }, failure: { error in
            self.collectionView.hideSkeleton(transition: .crossDissolve(0.25))
            self.collectionViewMenu.hideSkeleton(transition: .crossDissolve(0.25))
            self.refreshControls.endRefreshing()
            self.collectionView.reloadData()
            self.collectionViewMenu.reloadData()
        })
    }
    
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            if let itemInteractor = itemInteractor, itemInteractor.items.count != 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCollectionViewCell", for: indexPath) as! ItemCollectionViewCell
                cell.item = itemInteractor.getHeroList(role: selectedRole)[indexPath.row]
                return cell
            }
        } else if collectionView == self.collectionViewMenu {
            if let itemInteractor = itemInteractor, itemInteractor.getRoleList().count != 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCollectionViewCell", for: indexPath) as! MenuCollectionViewCell
                cell.menu = itemInteractor.getRoleList()[indexPath.row]
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView, let itemInteractor = self.itemInteractor {
            return itemInteractor.getHeroList(role: selectedRole).count
        } else if collectionView == self.collectionViewMenu, let itemInteractor = self.itemInteractor {
            return itemInteractor.getRoleList().count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView, let itemInteractor = itemInteractor, itemInteractor.getRoleList().count != 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCollectionViewCell", for: indexPath) as! ItemCollectionViewCell
            cell.freezeAnimations()
            
            let item = itemInteractor.getHeroList(role: selectedRole)[indexPath.row]
            let controller = DetailHeroViewController.instantiateViewController()
            controller.title = "\(item.name?.capitalized ?? "")"
            controller.item = item
            controller.similarityItems = itemInteractor.getSimilarHeroList(selectedHero: item)
            self.navigationController?.pushViewController(controller, animated: true)
        } else if collectionView == self.collectionViewMenu {
            if let itemInteractor = self.itemInteractor {
                self.selectedRole = itemInteractor.getRoleList()[indexPath.row]
                self.collectionView.reloadData()
            }
            
        }
    }
}

extension ViewController: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        if collectionView == self.collectionView {
            return "ItemCollectionViewCell"
        } else if collectionView == self.collectionViewMenu {
            return "MenuCollectionViewCell"
        }
        
        return ""
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.collectionView {
            if UIDevice().isPhone() {
                if DeviceInfo.Orientation.isLandscape {
                    let widthCollectionView = self.heightScreen - CGFloat(self.witdhCollectionViewMenu) - CGFloat(100)
                    let widthCard = widthCollectionView - CGFloat((marginCenter * 4)) / 3 // 20 margin center, left rifht center
                    let heightImage = 9/16 * widthCard
                    return CGSize(width: widthCard, height: heightImage + 100)
                } else {
                    let widthCollectionView = self.widthScreen - CGFloat(self.witdhCollectionViewMenu)
                    let widthCard = widthCollectionView - CGFloat((marginCenter * 2)) // 20 margin center, left rifht center
                    let heightImage = 9/16 * widthCard
                    return CGSize(width: widthCard, height: heightImage + 56)
                }
            }
        } else if collectionView == self.collectionViewMenu {
            return CGSize(width: 100, height: 40)
        }
        
        return CGSize.zero
    }
}

