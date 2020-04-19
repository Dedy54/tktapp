//
//  ImageInteractor?.swift
//  TiketTestApp
//
//  Created by Dedy Yuristiawan on 17/04/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import Foundation
import SwiftyJSON

class ItemInteractor: BaseInteractor {
    
    var currentPage = 0
    
    open var hasNext: Bool {
        return currentPage != -1
    }
    
    var items: [Item] = [Item]()
    var totalData: Int = 0
    
    func load(withCompletion completion: (() -> Void)? = nil) {
        items.removeAll()
        if let key = storeKey,
            let keyedValue = realm.object(ofType: KeyedValue.self, forPrimaryKey: key as AnyObject),
            let value = keyedValue.value {
            let json = JSON.parse(value)
            for child in json.arrayValue {
                if let item = realm.object(ofType: (Item.self), forPrimaryKey: child.rawValue as AnyObject) {
                    items.append(Item(value: item))
                }
            }
        }
    }
    
    func refresh(success: @escaping () -> (Void), failure: @escaping (NSError) -> (Void)) {
        currentPage = 1
        nextWith(success: success, failure: failure)
    }
    
    func nextWith(success: @escaping () -> (Void), failure: @escaping (NSError) -> (Void)) {
        service.getItems(params: params, page: currentPage, perPage: perPage, success: { pagination  in
            
            if pagination.currentPage == 1 {
                self.items.removeAll()
            }
            if pagination.currentPage >= pagination.lastPage {
                self.currentPage = -1
            } else {
                self.currentPage = pagination.currentPage + 1
            }
            
            self.items.append(contentsOf: pagination.data)
            self.totalData = pagination.total
            print("itemsitemsitems : \(self.items.count)")
            success()
        }, failure: { error in
            failure(error)
        })
        
    }
    
    func getRoleList() -> [String] {
        var menus = [String]()
        menus.append("All")
        for i in self.items {
            for j in i.roles {
                menus.append(j)
            }
        }
        
        return menus.unique()
    }
    
    func getHeroList(role : String? = "All") -> [Item] {
        if role == "All"{
            return self.items
        } else {
            return self.items.filter({ $0.roles.contains(role!)})
        }
    }
    
    func getSimilarHeroList(selectedHero: Item) -> [Item] {
        return self.items.filter({ $0.identifier != selectedHero.identifier && selectedHero.primaryAttr == $0.primaryAttr }).sorted(by: {
            if selectedHero.primaryAttr == "agi" {
                let firstHeroSpeed = $0.moveSpeed
                let secondHeroSpeed = $1.moveSpeed
                return firstHeroSpeed > secondHeroSpeed
            }
            else if selectedHero.primaryAttr == "str" {
                let firstHeroAttack = $0.moveSpeed
                let secondHeroAttack = $1.moveSpeed
                return firstHeroAttack > secondHeroAttack
            }
            else if selectedHero.primaryAttr == "int" {
                let firstHeroMana = $0.moveSpeed
                let secondHeroMana = $1.moveSpeed
                return firstHeroMana > secondHeroMana
            }
            
            return false
        }).limit(3)
    }

}
