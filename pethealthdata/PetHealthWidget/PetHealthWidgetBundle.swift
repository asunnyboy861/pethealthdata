//
//  PetHealthWidgetBundle.swift
//  PetHealthWidget
//
//  Created by MacMini4 on 2026/3/9.
//

import WidgetKit
import SwiftUI

@main
struct PetHealthWidgetBundle: WidgetBundle {
    var body: some Widget {
        PetHealthWidget()
        PetHealthWidgetControl()
        PetHealthWidgetLiveActivity()
    }
}
