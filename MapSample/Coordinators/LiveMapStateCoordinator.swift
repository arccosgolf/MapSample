//
//  LiveMapStateCoordinator.swift
//  MapSample
//
//  Created by Greg Silesky on 1/6/25.
//

import Foundation
import Combine

final class LiveMapStateCoordinator {
    
    var course: CurrentValueSubject<Course?, Never>
    var selectedHoleId: CurrentValueSubject<Int, Never> = CurrentValueSubject<Int, Never>(1)

    var selectedHoleData: CourseHole? {
        return course.value?.hole(for: selectedHoleId.value)
    }
    
    init() {
        do {
            guard let bundlePath = Bundle(for: type(of: self)).path(forResource: "Braemar", ofType: "json"),
                  let jsonData = try String.init(contentsOfFile: bundlePath, encoding: .utf8).data(using: .utf8) else {
                self.course = CurrentValueSubject<Course?, Never>(nil)
                return
            }
            let courseData = try JSONDecoder().decode(Course.self, from: jsonData)
            for index in 1...courseData.numberOfHoles {
                guard let bundlePath = Bundle(for: type(of: self)).path(forResource: "Braemar_\(index)", ofType: "json"),
                   let jsonData = try String.init(contentsOfFile: bundlePath, encoding: .utf8).data(using: .utf8) else { continue }
                let holeData = try JSONDecoder().decode(CourseHole.self, from: jsonData)
                courseData.holes.append(holeData)
            }
            self.course = CurrentValueSubject<Course?, Never>(courseData)
        }catch {
            self.course = CurrentValueSubject<Course?, Never>(nil)
        }
    }
    
    func onSelectedHoleChange(to holeId: Int) {
        selectedHoleId.send(holeId)
    }
}
