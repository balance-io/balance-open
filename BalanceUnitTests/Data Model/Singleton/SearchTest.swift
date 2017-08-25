//
//  SearchTest.swift
//  Bal
//
//  Created by Jamie Rumbelow on 15/09/2016.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import XCTest
@testable import BalancemacOS

class SearchTest: XCTestCase {
    
    func testTokenizeSearch() {
        XCTAssert(Search.tokenizeSearch("blah test") == nil)
        
        var SUT = Search.tokenizeSearch("in:(american)")
        XCTAssert(SUT?[SearchToken.in]?.value == "american")
        
        SUT = Search.tokenizeSearch("account:(american)")
        XCTAssert(SUT?[SearchToken.account]?.value == "american")
        
        SUT = Search.tokenizeSearch("amount:10")
        XCTAssert(SUT?[SearchToken.amount]?.value == "10")
        
        SUT = Search.tokenizeSearch("amount:\"$1000\"")
        XCTAssert(SUT?[SearchToken.amount]?.value == "$1000")
        
        SUT = Search.tokenizeSearch("name:Jamie")
        XCTAssert(SUT?[SearchToken.name]?.value == "Jamie")
        
        SUT = Search.tokenizeSearch("name=:(Rich)")
        XCTAssertEqual(SUT?[SearchToken.nameMatches]?.value, "Rich")
        
        SUT = Search.tokenizeSearch("category:(travel)")
        XCTAssert(SUT?[SearchToken.category]?.value == "travel")
        
        SUT = Search.tokenizeSearch("category:(travel) category:(food)")
        XCTAssert(SUT?[SearchToken.category]?.value == "food")
        
        SUT = Search.tokenizeSearch("category=:(ave)")
        XCTAssert(SUT?[SearchToken.categoryMatches]?.value == "ave")
    }
    
    func disable_testTransactionIdsMatchingTokens() {
        var ids: Set<Int>
        
        ids = Search.transactionIdsMatchingTokens([ SearchToken.in: "american express" ])
        XCTAssert( !ids.isEmpty )
        XCTAssert( ids.subtracting(amexIds).isEmpty )
        ids = Search.transactionIdsMatchingTokens([ SearchToken.account: "american express" ])
        XCTAssert( !ids.isEmpty )
        XCTAssert( ids.subtracting(amexIds).isEmpty )
        
        ids = Search.transactionIdsMatchingTokens([ SearchToken.amount: "1" ])
        XCTAssert( ids.count == exactly1Ids.count )
        XCTAssert( ids.subtracting(exactly1Ids).isEmpty )
        ids = Search.transactionIdsMatchingTokens([ SearchToken.amount: "1.00" ])
        XCTAssert( ids.count == exactly1Ids.count )
        XCTAssert( ids.subtracting(exactly1Ids).isEmpty )
        ids = Search.transactionIdsMatchingTokens([ SearchToken.amount: "$1.00" ])
        XCTAssert( ids.count == exactly1Ids.count )
        XCTAssert( ids.subtracting(exactly1Ids).isEmpty )
        

        
        ids = Search.transactionIdsMatchingTokens([ SearchToken.category: "travel" ])
        XCTAssert( ids.count == travelIds.count )
        XCTAssert( ids.subtracting(travelIds).isEmpty )
    
        XCTAssert( ids.count == travelLessThan15Ids.count )
        XCTAssert( ids.subtracting(travelLessThan15Ids).isEmpty )
        
        XCTAssert( ids.count == sinceAugustIds.count )
        XCTAssert( ids.subtracting(sinceAugustIds).isEmpty )
        XCTAssert( ids.count == sinceAugustIds.count )
        XCTAssert( ids.subtracting(sinceAugustIds).isEmpty )
    }
    
    
    //
    // MARK: Testing Data
    //
    
    let exactly1Ids = Set([706, 3100, 2122, 678, 322, 373])
    
    let lessThan5Ids = Set([1892, 2247, 2806, 2148, 2548, 2493, 1574, 167, 108, 955, 2203, 2837, 3224, 2553, 2995, 1143, 1345, 1703, 268, 425, 3031, 2037, 310, 193, 2028, 238, 1902, 209, 571, 624, 437, 1405, 3027, 3243, 297, 2807, 327, 678, 3145, 1207, 764, 331, 191, 2182, 2131, 1666, 269, 1924, 3029, 3144, 3040, 329, 335, 2443, 3245, 166, 2047, 1930, 2031, 1276, 2395, 228, 253, 1822, 2973, 180, 211, 2425, 2358, 3232, 2122, 1852, 749, 2829, 3100, 303, 2326, 3235, 486, 2024, 3239, 783, 1221, 72, 239, 426, 2604, 2629, 3023, 827, 3237, 1176, 2965, 980, 3231, 3233, 2881, 796, 3250, 2056, 1932, 2317, 444, 2032, 2500, 659, 207, 574, 3068, 598, 2860, 338, 2405, 1797, 373, 692, 710, 370, 2467, 2123, 1043, 3065, 2232, 173, 988, 3249, 909, 322, 855, 1580, 186, 2288, 2819, 265, 2870, 2913, 1891, 299, 106, 2318, 726, 2316, 2085, 3042, 3248, 2890, 1752, 314, 666, 2335, 150, 702, 2181, 1536, 2694, 2071, 261, 2883, 1369, 1021, 151, 1781, 2576, 172, 2878, 3242, 420, 2106, 2845, 2267, 3081, 2324, 3007, 3013, 2880, 203, 881, 886, 706, 3022, 2963, 2551, 2782, 3236, 3142, 447, 2572, 2891, 397, 2897, 3238, 3251, 1638, 2050])
    
    let moreThan10000Ids = Set([549, 2569, 551, 506, 296, 1246, 2178, 295, 2059, 487, 485, 513])
    
    let amexIds = Set([935, 1094, 1691, 1847, 965, 761, 1243, 1582, 1751, 1629, 1809, 1909, 1242, 1523, 1510, 1727, 875, 804, 765, 1685, 1746, 2553, 1760, 873, 1616, 1643, 1703, 1816, 1233, 1780, 766, 985, 964, 1628, 986, 1902, 1128, 601, 1726, 752, 733, 1209, 1877, 699, 1927, 865, 622, 1678, 1639, 764, 1622, 1546, 1396, 1419, 878, 668, 763, 877, 655, 1725, 740, 1799, 1881, 1861, 618, 1860, 1821, 1093, 1684, 1682, 1852, 2829, 735, 1735, 1334, 1371, 1573, 625, 781, 1234, 638, 1373, 885, 1268, 1618, 1738, 1491, 1610, 1880, 872, 1512, 1719, 1729, 1737, 1835, 1521, 1135, 621, 1248, 620, 608, 780, 1596, 1145, 1910, 596, 1731, 1244, 1670, 595, 1761, 1184, 1769, 1607, 1614, 1681, 1765, 1547, 1947, 1804, 1653, 656, 1963, 1801, 2961, 593, 1699, 652, 1039, 1399, 1792, 1091, 1374, 778, 591, 1768, 1683, 1708, 874, 1872, 2947, 921, 1724, 1361, 1707, 1625, 1805, 1858, 711, 803, 1802, 614, 1092, 628, 594, 1790, 782, 1823, 1615, 1762, 1511, 1011, 1834, 756, 1522, 726, 1259, 1745, 1208, 879, 1779, 888, 729, 967, 603, 1451, 1694, 650, 734, 1752, 957, 1800, 1026, 1897, 1565, 666, 762, 887, 1715, 1771, 883, 966, 1080, 1794, 2990, 960, 1756, 1723, 1796, 657, 1807, 2866, 1256, 1372, 1785, 1450, 1482, 640, 592, 1698, 1619, 1085, 1810, 779, 1758, 1803, 1060, 1232, 1365, 1311, 1282, 2875, 798])
    
    let travelIds = Set([12, 65, 14, 49, 7, 68, 71, 58, 70, 2, 39, 46, 6, 36, 69, 3246, 1, 8])
    let travelLessThan15Ids = Set([12, 14, 2, 6, 7, 36, 1])
    
    let sinceAugustIds = Set([17, 14, 30, 3055, 3160, 3, 32, 258, 3059, 28, 602, 6, 50, 3053, 12, 3154, 23, 25, 3156, 3159, 3045, 5, 593, 598, 45, 3048, 11, 37, 2, 273, 255, 268, 3246, 591, 3161, 3261, 257, 274, 3158, 27, 3162, 3049, 3259, 601, 3153, 21, 9, 3155, 44, 3264, 3056, 35, 256, 260, 262, 599, 3046, 597, 15, 29, 52, 56, 271, 275, 276, 594, 22, 267, 18, 53, 265, 269, 36, 57, 263, 3051, 3265, 41, 3058, 20, 49, 3260, 38, 42, 47, 39, 34, 46, 603, 266, 7, 43, 272, 3052, 16, 590, 51, 264, 600, 31, 26, 261, 3057, 8, 270, 40, 24, 259, 13, 3047, 19, 3262, 1, 3050, 3054, 10, 55, 592, 48, 596, 33, 54, 3157, 4, 595, 3263])
}
