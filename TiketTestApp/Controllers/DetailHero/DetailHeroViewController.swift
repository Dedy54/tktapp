//
//  DetailHeroViewController.swift
//  TiketTestApp
//
//  Created by Dedy Yuristiawan on 19/04/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit

class DetailHeroViewController: UIViewController {

    var similarityItems : [Item] = [Item]()
    var item : Item?
    
    @IBOutlet weak var heroImage: UIImageView!{
        didSet{
            heroImage.clipsToBounds = true
            heroImage.layer.cornerRadius = 8
            heroImage.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var healthLabel: UILabel!
    @IBOutlet weak var maxAttackLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var rolesLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.register(UINib(nibName: "ItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ItemCollectionViewCell")
            collectionView.delaysContentTouches = false
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.alwaysBounceHorizontal = true
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.minimumLineSpacing = 20
                layout.minimumInteritemSpacing = 0
                layout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
            }
        }
    }
    
    static func instantiateViewController() -> DetailHeroViewController {
        let controller = R.storyboard.detailHero.detailHeroViewController()!
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    func setupUI() {
        if let item = self.item {
            if let url = URL(string: "\(CoreService.instance.home)\(item.img ?? "")") {
                heroImage.kf.indicatorType = .activity
                heroImage.kf.setImage(with: url, options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ], progressBlock: nil) { (image, error, cacheType, url) in
                }
            }
            
            nameLabel.text = item.name ?? ""
            
            healthLabel.text = "Health \(item.baseHealth)"
            maxAttackLabel.text = "Max Attack \(item.baseAttackMax)"
            speedLabel.text = "Speed \(item.moveSpeed)"
            rolesLabel.text = "Roles \(item.primaryAttr ?? "")"
            
            if similarityItems.count != 0 {
                collectionView.reloadData()
            }
        }
        
        self.collectionView.hideSkeleton(transition: .crossDissolve(0.25))
    }

}

extension DetailHeroViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionView {
            if similarityItems.count != 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCollectionViewCell", for: indexPath) as! ItemCollectionViewCell
                cell.item = similarityItems[indexPath.row]
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return similarityItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCollectionViewCell", for: indexPath) as! ItemCollectionViewCell
            cell.freezeAnimations()
            
        }
    }
}

extension DetailHeroViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == collectionView {
            return CGSize(width: 256, height: 200)
        }
        
        return CGSize.zero
    }
}
