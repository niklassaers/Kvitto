//
//  InAppPurchaseReceipt.swift
//  Kvitto
//
//  Created by Oliver Drobnik on 07/10/15.
//  Copyright © 2015 Oliver Drobnik. All rights reserved.
//

import Foundation
import DTFoundation

/**
 A purchase receipt for an IAP
*/
@objc(DTInAppPurchaseReceipt) public final class InAppPurchaseReceipt: NSObject
{
    /**
    The number of items purchased. This value corresponds to the quantity property of the SKPayment object stored in the transaction’s payment property.
    */
    private(set) public var quantity: Int?
    
    /**
    The product identifier of the item that was purchased. This value corresponds to the productIdentifier property of the SKPayment object stored in the transaction’s payment property.
    */
    private(set) public var productIdentifier: String?
    
    /**
    The transaction identifier of the item that was purchased. This value corresponds to the transaction’s transactionIdentifier property.
    */
    private(set) public var transactionIdentifier: String?
    
    /**
    For a transaction that restores a previous transaction, the transaction identifier of the original transaction. Otherwise, identical to the transaction identifier. This value corresponds to the original transaction’s transactionIdentifier property.
    
    All receipts in a chain of renewals for an auto-renewable subscription have the same value for this field.
    */
    private(set) public var originalTransactionIdentifier: String?
    
    /**
    The date and time that the item was purchased. This value corresponds to the transaction’s transactionDate property.
    
    For a transaction that restores a previous transaction, the purchase date is the date of the restoration. Use Original Purchase Date to get the date of the original transaction.
    
    In an auto-renewable subscription receipt, this is always the date when the subscription was purchased or renewed, regardless of whether the transaction has been restored.
    */
    private(set) public var purchaseDate: NSDate?
    
    /**
    For a transaction that restores a previous transaction, the date of the original transaction. This value corresponds to the original transaction’s transactionDate property.
    
    In an auto-renewable subscription receipt, this indicates the beginning of the subscription period, even if the subscription has been renewed.
    */
    private(set) public var originalPurchaseDate: NSDate?
    
    /**
    The expiration date for the subscription. This key is only present for auto-renewable subscription receipts.
    */
    private(set) public var subscriptionExpirationDate: NSDate?
    
    /**
    For a transaction that was canceled by Apple customer support, the time and date of the cancellation. Treat a canceled receipt the same as if no purchase had ever been made.
    */
    private(set) public var cancellationDate: NSDate?
    
    /**
    The primary key for identifying subscription purchases.
    */
    private(set) public var webOrderLineItemIdentifier: Int?
    
    /**
    The designated initializer
    */
    public init?(data: NSData)
    {
        super.init()
        
        do
        {
            try parseData(data)
        }
        catch
        {
            return nil
        }
    }
    
    // MARK: Parsing
    
    private func parseData(data: NSData) throws -> Bool
    {
        guard let rootArray = DTASN1Serialization.objectWithData(data) as? [[AnyObject]]
            else
        {
            throw ReceiptParsingError.InvalidRootObject
        }
        
        for var item in rootArray
        {
            guard item.count == 3,
                let type = (item[0] as? NSNumber)?.integerValue,
                version = (item[1] as? NSNumber)?.integerValue,
                data = item[2] as? NSData
                where version > 0
                else
            {
                throw ReceiptParsingError.InvalidRootObject
            }
            
            try processItem(type, data: data)
        }
        
        return true
    }
    
    private func processItem(type: Int, data: NSData) throws
    {
        switch(type)
        {
        case 1701:
            quantity = try _intFromData(data)
            
        case 1702:
            productIdentifier = try _stringFromData(data)
            
        case 1703:
            transactionIdentifier = try _stringFromData(data)
            
        case 1704:
            purchaseDate = try _dateFromData(data)
            
        case 1705:
            originalTransactionIdentifier = try _stringFromData(data)
            
        case 1706:
            originalPurchaseDate = try _dateFromData(data)
            
        case 1708:
            subscriptionExpirationDate = try _dateFromData(data)
            
        case 1711:
            webOrderLineItemIdentifier = try _intFromData(data)
            
        case 1712:
            cancellationDate = try _dateFromData(data)
            
        default:
            // all other types are private
            break;
        }
    }
}
