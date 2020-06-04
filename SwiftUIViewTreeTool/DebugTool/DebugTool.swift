//
//  DebugTool.swift
//  SwiftUILayoutDemo
//
//  Created by zlc on 2020/6/3.
//  Copyright © 2020 open.tool.app. All rights reserved.
//

import SwiftUI

extension View {
    func debug() -> Self {
        print(Mirror(reflecting: self).subjectType)
        return self
    }
    
    func subjectTypeInfo() -> String {
        let subjectType = Mirror(reflecting: self).subjectType
        return String(describing: subjectType)
    }
}
