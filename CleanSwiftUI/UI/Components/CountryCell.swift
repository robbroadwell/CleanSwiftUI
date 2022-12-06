//
//  CountryCell.swift
//  CleanSwiftUI
//
//  Created by Rob Broadwell on 10/17/22.
//

import SwiftUI

struct CountryCell: View {
    
    let country: Country
    @Environment(\.locale) var locale: Locale
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(country.name(locale: locale))
                .font(.title)
            Text("Population \(country.population)")
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 60, alignment: .leading)
    }
}

#if DEBUG
struct CountryCell_Previews: PreviewProvider {
    static var previews: some View {
        CountryCell(country: Country.mockedData[0])
            .previewLayout(.fixed(width: 375, height: 60))
    }
}
#endif
