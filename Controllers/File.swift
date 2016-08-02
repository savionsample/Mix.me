import Foundation


class MinCoinChange {
    
    class func minCoinDynamic(amount amount: Int, coins: [Int]) -> Int{
        var coinReq: [Int] = [Int](count: amount + 1, repeatedValue: -1)
        var CC: [Int]
        coinReq[0] = 0
        
        for amnt in 1 ... amount {
            // print("Solving for Amount: \(amnt)")
            CC = [Int](count: coins.count,repeatedValue: 999)
            
            for j in 0 ... coins.count-1 {
                if coins[j] <= amnt {
                    // print("Coin Requirement for \(amnt - coins[j])")
                    // print("using Coin \(coins[j]) : \(coinReq[amnt - coins[j]])")
                    
                    CC[j] = coinReq[amnt - coins[j]] + 1
                    
                    
                    
                }
            }
            
            if let foo = CC.minElement(){
                coinReq[amnt] = foo
            }
            
            
        }
        
        
        return coinReq[amount]
    }
    
}

//print(">>\(MinCoinChange.MinCoinDynamic(amount: 20, coins: [1,2,3]))")