//
//  Int64+Ext.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 10.09.2021.
//

import Foundation

extension Int64 {
    var bandwidthGBString: String {
        String(format: "%.2f", bandwidthMB / 1000)
    }

    var bandwidthMB: Double {
        return bandwidthKB / 1000
    }
    
    var bandwidthKB: Double {
        return Double(self) / 1000
    }

    var bandwidthMBString: String {
        String(format: "%.2f MB", bandwidthMB)
    }
}

// TODO: Should be refactor somehow
extension Int {
    var getBandwidthKBorMB: (String, String) {
        let int64 = Int64(Float(self))
        let kb = int64.bandwidthKB
        
        if kb >= 1000 {
            return (String(format: "%.2f", int64.bandwidthMB), "MB/s")
        } else {
            return (String(format: "%.2f", kb), "KB/s")
        }
    }

    var pricePersentage: Double {
        let raw = Double(self) / 10_000_000
        if raw > 1 { return 0 }
        if raw < 0 { return 1 }
        return 1 - raw
    }
}

extension Int64 {
    func secondsAsString(with style: DateComponentsFormatter.UnitsStyle = .abbreviated) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = style
        return formatter.string(from: Double(self)) ?? ""
    }
}
