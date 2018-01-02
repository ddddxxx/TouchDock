//
//  Collection+Extension.swift
//
//  This file is part of TouchDock
//  Copyright (C) 2017  Xander Deng
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

extension RangeReplaceableCollection {
    
    mutating func move(at oldIndex: Self.Index, to newIndex: Self.Index) {
        guard oldIndex != newIndex else {
            return
        }
        let item = remove(at: oldIndex)
        insert(item, at: newIndex)
    }
}

extension Collection {
    
    subscript(safe index: Self.Index) -> Self.Iterator.Element? {
        guard index < endIndex else {
            return nil
        }
        return self[index]
    }
}
