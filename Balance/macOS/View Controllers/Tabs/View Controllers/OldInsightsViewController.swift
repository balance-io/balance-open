//
//  OldInsightsTabViewController.swift
//  Bal
//
//  Created by Benjamin Baron on 2/9/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

import Cocoa
import SnapKit
import Charts

class OldInsightsTabViewController: NSViewController {
    
    //
    // MARK: - Properties -
    //
    
    let dateFormatter = NSDateFormatter()
    
    // MARK: Body
    var scrollView = ScrollView()
    var documentView = View()
    var barChartView = BarChartView()
    var transactionChartView = BarChartView()
    let hypeField = LabelField()
    let hypeImage = ImageView()
    
    // MARK: Footer
    let footerView = View()
    let balanceField = LabelField()
    let totalField = LabelField()
    
    //
    // MARK: - Lifecycle -
    //
    
    init() {
        super.init(nibName: nil, bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        async {
            AppDelegate.sharedInstance.resizeWindow(CurrentTheme.defaults.size, animated: true)
        }
    }
    
    //
    // MARK: - View Creation -
    //
    
    override func loadView() {
        self.view = View()
        
        if debugging.showInsightsComingSoon {
            hypeField.alignment = .Center
            hypeField.font = NSFont.systemFontOfSize(14)
            hypeField.textColor = CurrentTheme.defaults.foregroundColor
            hypeField.layer?.backgroundColor = NSColor(deviceRed:0.07, green:0.50, blue:0.00, alpha:1.00).CGColor
            hypeField.usesSingleLineMode = false
            hypeField.alphaValue = 1
            hypeField.stringValue = "Coming soon. This is not your data."
            self.view.addSubview(hypeField)
            hypeField.snp.makeConstraints { make in
                make.leading.equalTo(self.view)
                make.trailing.equalTo(self.view)
                make.height.equalTo(20)
                make.top.equalTo(self.view).inset(5)
            }
            
            hypeImage.image = NSImage(named: "insightsPreview")
            hypeImage.wantsLayer = true
            hypeImage.borderWidth = 0.5
            hypeImage.borderColor = CurrentTheme.defaults.foregroundColor.colorWithAlphaComponent(0.5)
            self.view.addSubview(hypeImage)
            hypeImage.snp.makeConstraints { make in
                make.width.equalTo(336)
                make.height.equalTo(484)
                make.centerX.equalTo(self.view)
                make.top.equalTo(hypeField.snp.bottom).offset(20)
            }
        } else {

            self.view.addSubview(scrollView)
            
            scrollView.snp.makeConstraints { make in
                make.leading.equalTo(self.view)
                make.trailing.equalTo(self.view)
                make.height.equalTo(self.view)
                make.top.equalTo(self.view)
            }
            
            scrollView.documentView = documentView
            
            documentView.snp.makeConstraints { make in
                make.leading.equalTo(self.view).inset(5)
                make.trailing.equalTo(self.view).inset(-5)
                make.height.equalTo(650)
                make.top.equalTo(self.view).offset(5)
            }
            
            documentView.addSubview(barChartView)
            
            barChartView.snp.makeConstraints { make in
                make.leading.equalTo(documentView)
                make.trailing.equalTo(documentView)
                make.height.equalTo(300)
                make.top.equalTo(self.view).offset(10)
            }
            
            createBarGraph()
            
            documentView.addSubview(transactionChartView)
            
            transactionChartView.snp.makeConstraints { make in
                make.leading.equalTo(documentView)
                make.trailing.equalTo(documentView)
                make.height.equalTo(300)
                make.top.equalTo(barChartView.snp.bottom).offset(20)
            }
            
            createTransactionGraph()
        }
    }
    
    struct TransactionDataPoint {
        var day: String
        var value: Double
    }
    
    class DataGenerator {
        
        static var randomizedTransaction: Double {
            return Double(arc4random_uniform(10000) + 1) / 10
        }
                
        static func data() -> [TransactionDataPoint] {
            let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun","Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun","Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun","Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            var transactionDataPoints = [TransactionDataPoint]()
            
            for day in days {
                let transactionDataPoint = TransactionDataPoint(day: day, value: randomizedTransaction)
                transactionDataPoints.append(transactionDataPoint)
            }
            
            return transactionDataPoints
        }
    }
    
    
    func createBarGraph() {
        dateFormatter.dateFormat = "MMM"
        
        let data = insights.incomeAndSpendingTotalByMonth(6)
        var incomeEntries = [ChartDataEntry]()
        var spendingEntries = [ChartDataEntry]()
        var dataLabels = [String]()
        var maxValue = 0.0
        
        let sortedKeys = data.keys.sort { return $0 < $1 }
        for i in 0...sortedKeys.count-1 {
            let key = sortedKeys[i]
            let value = data[key]!
            let income = -(Double(value.income) / 100.0)
            let spending = Double(value.spending) / 100.0
            
            let formattedDate = dateFormatter.stringFromDate(key)
            dataLabels.append(formattedDate)
            
            let incomeEntry = BarChartDataEntry(value: income, xIndex: i)
            incomeEntries.append(incomeEntry)

            let spendingEntry = BarChartDataEntry(value: spending, xIndex: i)
            spendingEntries.append(spendingEntry)
            
            if income > maxValue {
                maxValue = income
            }
            if spending > maxValue {
                maxValue = spending
            }
        }
        
        let incomeDataSet = BarChartDataSet(yVals: incomeEntries, label: "Income")
        incomeDataSet.colors = [NSUIColor.greenColor()]
        let spendingDataSet = BarChartDataSet(yVals: spendingEntries, label: "Spending")
        spendingDataSet.colors = [NSUIColor.redColor()]
        let chartData = BarChartData(xVals: dataLabels, dataSets: [incomeDataSet, spendingDataSet])
        chartData.setDrawValues(false)
        
        barChartView.data = chartData
        
        barChartView.xAxis.labelPosition = .Bottom
        barChartView.xAxis.drawGridLinesEnabled = true
        barChartView.rightAxis.enabled = false
        barChartView.leftAxis.enabled = true
        barChartView.dragEnabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.scaleXEnabled = false
        barChartView.scaleYEnabled = true
        barChartView.leftAxis.labelTextColor = NSUIColor.lightGrayColor()
        barChartView.leftAxis.axisMinValue = 0.0
        barChartView.leftAxis.axisMaxValue = maxValue
        
        barChartView.xAxis.labelTextColor = NSUIColor.lightGrayColor()
        barChartView.xAxis.drawGridLinesEnabled = false
        
        barChartView.infoTextColor = NSUIColor.grayColor()
        barChartView.legend.enabled = true
        barChartView.legend.form = .Circle
        barChartView.legend.horizontalAlignment = .Center
        barChartView.legend.textColor = NSUIColor.whiteColor()
        
        //Another nice option is choosing bars by tapping them. Then you can show some kind of balloon with value or description. We don’t need that in our case, so selection can be disabled.
        barChartView.highlighter = nil
        barChartView.descriptionText = ""
    }
    
    func createTransactionGraph() {
        dateFormatter.dateFormat = "MMM d"
        
        let data = insights.spendingTotalByDay(30)
        var dataEntries = [ChartDataEntry]()
        var dataLabels = [String]()
        var maxValue = 0.0
        
        let sortedKeys = data.keys.sort { return $0 < $1 }
        for i in 0...sortedKeys.count-1 {
            let key = sortedKeys[i]
            let value = Double(data[key]!) / 100.0
            
            let formattedDate = dateFormatter.stringFromDate(key)
            dataLabels.append(formattedDate)
            
            let entry = BarChartDataEntry(value: value, xIndex: i)
            dataEntries.append(entry)
            
            if value > maxValue {
                maxValue = value
            }
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Spending")
        let chartData = BarChartData(xVals: dataLabels, dataSets: [chartDataSet])
        
        chartData.setDrawValues(false)
        
        transactionChartView.data = chartData
        
        transactionChartView.xAxis.labelPosition = .Bottom
        
        transactionChartView.xAxis.labelRotationAngle = 0 // setting this anything but 0 flips the chart over?
        transactionChartView.xAxis.spaceBetweenLabels = 400 // this doesn't seem to have an effect
        transactionChartView.xAxis.avoidFirstLastClippingEnabled = true // this doesn't seem to have an effect
        transactionChartView.xAxis.wordWrapEnabled = false // this cuts off the label
        transactionChartView.xAxis.setLabelsToSkip(4) // this doesn't seem to have an effect
        
        
        transactionChartView.xAxis.drawGridLinesEnabled = true
        
        transactionChartView.drawHighlightArrowEnabled = true
        transactionChartView.drawValueAboveBarEnabled = true
//        transactionChartView.drawBarShadowEnabled = true
//        transactionChartView.shadow = NSShadow()
        
        transactionChartView.rightAxis.enabled = false
        transactionChartView.leftAxis.enabled = true
        transactionChartView.dragEnabled = true //this doesn't seem to have an effect—perhaps it needs more data?
        transactionChartView.pinchZoomEnabled = false
        transactionChartView.doubleTapToZoomEnabled = false //no transiton. Jumps from one state to another
        transactionChartView.scaleXEnabled = false
        transactionChartView.scaleYEnabled = true
        transactionChartView.leftAxis.labelTextColor = NSUIColor.lightGrayColor()
        transactionChartView.leftAxis.axisMinValue = 0.0
        transactionChartView.leftAxis.axisMaxValue = maxValue
        
        transactionChartView.leftAxis.axisLineDashLengths = [10,5]
        transactionChartView.xAxis.drawGridLinesEnabled = true
        transactionChartView.leftAxis.drawGridLinesEnabled = false
        transactionChartView.xAxis.gridAntialiasEnabled = false
        
//        public var labelFont: NSFont
//        public var labelTextColor: NSColor
//        public var axisLineColor: NSColor
//        public var axisLineWidth: CGFloat
//        public var axisLineDashPhase: CGFloat
//        public var axisLineDashLengths: [CGFloat]!
//        public var gridColor: NSColor
//        public var gridLineWidth: CGFloat
//        public var gridLineDashPhase: CGFloat
//        public var gridLineDashLengths: [CGFloat]!
//        public var gridLineCap: CGLineCap
//        public var drawGridLinesEnabled: Bool
//        public var drawAxisLineEnabled: Bool
        
        transactionChartView.xAxis.labelTextColor = NSUIColor.lightGrayColor()
        
        
        transactionChartView.leftAxis.drawTopYLabelEntryEnabled = false
        
        transactionChartView.xAxis.drawLabelsEnabled = true
        
        transactionChartView.infoTextColor = NSUIColor.grayColor()
        transactionChartView.legend.enabled = true
        transactionChartView.legend.form = .Circle
        transactionChartView.legend.horizontalAlignment = .Center
        transactionChartView.legend.textColor = NSUIColor.whiteColor()
        
        //Another nice option is choosing bars by tapping them. Then you can show some kind of balloon with value or description. We don’t need that in our case, so selection can be disabled.
        transactionChartView.highlighter = nil
        
        transactionChartView.descriptionText = ""
    }
}
