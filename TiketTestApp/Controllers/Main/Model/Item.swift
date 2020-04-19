//
//  AwardsType.swift
//  TiketTestApp
//
//  Created by Dedy Yuristiawan on 17/04/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class Item: Object {
    
    @objc dynamic var identifier : Int64 = 0
    @objc dynamic var name: String?
    @objc dynamic var primaryAttr: String?
    @objc dynamic var attackType: String?
    @objc dynamic var img: String?
    @objc dynamic var moveSpeed: Int = 0
    @objc dynamic var baseAttackMax: Int = 0
    @objc dynamic var baseMana: Int = 0
    @objc dynamic var baseHealth: Int = 0
    
    public let roles = List<String>()
    
    override public static func primaryKey() -> String? {
        return "identifier"
    }
    
    public static func with(realm: Realm, json: JSON) -> Item? {
        let identifier = json["id"].int64Value
        if identifier == nil {
            return nil
        }
        var obj = realm.object(ofType: Item.self, forPrimaryKey: identifier)
        if obj == nil {
            obj = Item()
            obj?.identifier = identifier
        } else {
            obj = Item(value: obj!)
        }
        if json["name"].exists() {
            obj?.name = json["name"].stringValue.replacingOccurrences(of: "_", with: " ", options: .literal, range: nil)
        }
        if json["primary_attr"].exists() {
            obj?.primaryAttr = json["primary_attr"].stringValue
        }
        if json["attack_type"].exists() {
            obj?.attackType = json["attack_type"].stringValue
        }
        if json["img"].exists() {
            obj?.img = json["img"].stringValue
        }
        if json["move_speed"].exists() {
            obj?.moveSpeed = json["move_speed"].intValue
        }
        if json["base_attack_max"].exists() {
            obj?.baseAttackMax = json["base_attack_max"].intValue
        }
        if json["base_mana"].exists() {
            obj?.baseMana = json["base_mana"].intValue
        }
        if json["base_health"].exists() {
            obj?.baseHealth = json["base_health"].intValue
        }
        if json["roles"].exists() {
            obj?.roles.removeAll()
            for itemJson in json["roles"].arrayValue {
                obj?.roles.append(itemJson.stringValue)
            }
        }
        
        return obj
    }
    
    public static func with(json: JSON) -> Item? {
        return with(realm: try! Realm(), json: json)
    }
}
