//
//  HabitGridModel.swift
//  Tailor
//
//  Created by Logan Allen on 2/22/16.
//  Copyright © 2016 Logan Allen. All rights reserved.
//

import Bond

class HabitGridModel: ViewModel {
    var databaseService: DatabaseService!
    
    var allCards = ObservableArray<CardData>([])

    override init(coordinator: AppCoordinator) {
        super.init(coordinator: coordinator)
        databaseService = coordinator.databaseCoordinator!.databaseService
    }

    func setup() {

        appData?.allHabits.observe({ event in
            self.allCards.diffInPlace(event.sequence.map({ (habit: Habit) -> CardData in
                let cardData = HabitGridCardData()
                cardData.habit = habit
                return cardData
            }))
        })

    }

    // MARK: - User Events
    func addTapped() {
        databaseService.insertHabit(
            "Running",
            weekDays: Set<WeekDay>(arrayLiteral: WeekDay.Monday, WeekDay.Tuesday)
        )
    }

    func handleCollectionTapped(index: NSIndexPath) {
        // set current habit in app data store
        // open individual habit view
        // appData?.currentHabit.next(self.allHabits[index.row])
        let viewHabit = routeCoordinator.routeEnumToURL(routesEnum.viewHabit)
        routeCoordinator.navigateToRoute(viewHabit, options: nil)
    }

    func handleCollectionPressed(index: NSIndexPath) {
        // databaseService.insertEntry(self.allHabits[index.row])
        /*allHabits.performBatchUpdates{ array in
            let habit = array.removeAtIndex(index.row)
            habit.isTodayComplete = true
            array.insert(habit, atIndex: index.row)
        }*/
    }
}