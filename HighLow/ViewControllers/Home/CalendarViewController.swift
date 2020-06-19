//
//  CalendarViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 9/19/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController, JTACMonthViewDataSource, JTACMonthViewDelegate {
    
    var fulFilledDays: [String: String] = [:]
    
    weak var delegate: CalendarViewControllerDelegate?
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        
        return ConfigurationParameters(startDate: startDate, endDate: endDate, generateInDates: .off, generateOutDates: .off, hasStrictBoundaries: true)
    }
    
    func configureCell(view: JTACDayCell?, cellState: CellState) {
        guard let cell = view as? DateCell  else { return }
        cell.dateLabel.text = cellState.text
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: cellState.date)
        cell.isFulfilled = false
        if fulFilledDays[dateString] != nil {
            cell.isFulfilled = true
        }
        let todayDateString = dateFormatter.string(from: Date())
        if dateString == todayDateString {
            cell.bubble.backgroundColor = AppColors.secondary
            cell.dateLabel.textColor = .white
        }
        
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        
        return cell
    }
        
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
       configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        let formatter = DateFormatter()  // Declare this outside, to avoid instancing this heavy class multiple times.
        formatter.dateFormat = "MMMM yyyy"
        
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "DateHeader", for: indexPath) as! DateHeader
        header.monthTitle.text = formatter.string(from: range.start)
        return header
    }

    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
        return MonthSize(defaultSize: 50)
    }
    
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let dateString = formatter.string(from: date)
        let todayString = formatter.string(from: Date())
        
        if dateString == todayString {
            self.dismiss(animated: true, completion: {
                self.delegate?.calendarViewController(willOpenHighLowWithDate: todayString)
            })
            return
        }
        
        if fulFilledDays[dateString] != nil {
            self.dismiss(animated: true, completion: {
                self.delegate?.calendarViewController(willOpenHighLowWithDate: dateString)
            })
        }
        
    }
    
    
    var startDate: Date = Date()
    var endDate: Date = Date()
    
    
    @IBOutlet var calendarView: JTACMonthView!
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        
        calendarView.scrollDirection = .horizontal
        calendarView.scrollingMode = .stopAtEachCalendarFrame
        calendarView.isScrollEnabled = true
        
        calendarView.isHidden = true
        
        loadCalendar()
    }
    
    func findStartAndEndDates() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for day in fulFilledDays {
            if let date = dateFormatter.date(from: day.key) {
                if date < startDate {
                    startDate = date
                }
                
                if date > endDate {
                    endDate = date
                }
            }
            
        }
    }
    
    func loadCalendar() {
        
        authenticatedRequest(url: "/user/calendar", method: .get, parameters: [:], onFinish: { json in
            
            if let highlows = json["calendar"] as? [NSDictionary] {
                for i in highlows.indices {
                    self.fulFilledDays[ highlows[i]["_date"] as! String ] = highlows[i]["highlowid"] as? String
                }
                
                self.findStartAndEndDates()
                            
                self.calendarView.reloadData()
                
                self.calendarView.scrollToDate(self.endDate, completionHandler: {
                    self.calendarView.isHidden = false
                })
                
            }
                    
        }, onError: { error in
            alert("An error occurred", "Please try again.")
        })
        
    }

}

protocol CalendarViewControllerDelegate: AnyObject {
    func calendarViewController( willOpenHighLowWithId id: String )
    func calendarViewController( willOpenHighLowWithDate date: String)
}
