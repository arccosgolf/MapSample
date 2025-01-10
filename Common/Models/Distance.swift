//
//  Distance.swift
//
//  Created by Greg Silesky on 6/15/23.
//

import Foundation

let METERS_TO_YARDS = 1.09361
let YARDS_TO_METERS = 0.9144
let MILES_TO_KM = 1.609

enum DistanceScale : Int {
    case long, medium, short
}

class Distance: NSObject, Codable, NSSecureCoding, Comparable {
    static var supportsSecureCoding: Bool = true
    
    
    open var value:Double = 0
    
    // MARK: - Comparators
    func lessThan(_ distance:Distance?) -> Bool {
        if let d = distance {
            return value < d.value
        }
        return false
    }
    
    func greaterThan(_ distance:Distance?) -> Bool {
        if let d = distance {
            return value > d.value
        }
        return false
    }
    
    override open func isEqual(_ object: Any?) -> Bool {
        if let d = object as? Distance{
            return value == d.value
        }
        return false
    }
    
    // MARK: - Class Methods
    static func zeroDistance() -> Distance {
        return Distance(meters: 0)
    }
    
    static func maxDistance() -> Distance {
        return Distance(meters: Double(MAXFLOAT))
    }
    
    // MARK: - Initalizers
    override init(){
        super.init()
    }
    
    init(meters:Double){
        self.value = meters
    }
    
    init(yards:Double){
        self.value = yards * YARDS_TO_METERS
    }
    
    // MARK: - Computed Properties
    var yardsValue:Double {
        return self.value * METERS_TO_YARDS
    }
    
    var metersValue:Double {
        return self.value
    }
    
    // MARK: - Methods for Calculation
    /**
     Used for numerical distance calculations only. Should never be called for display strings. Use displayString/Value/Unit for this purpose.
     - parameter scale: Short, Medium, Long
     - returns: Double in yards or meters, depending on user preference
     */
    func calcValue(_ scale:DistanceScale) -> Double{
        var v:Double
        
        if useJapanese {
            switch scale {
            case .long:
                v = self.value * METERS_TO_YARDS
            case .short:
                v = self.value
            default:
                v = self.value * METERS_TO_YARDS
            }
        }
        else if useMetric {
            switch scale {
            case .long: v = (self.value / 1000)
            default: v = value
            }
        } else {
            switch scale {
            case .long:
                v = (self.value / 1000 / MILES_TO_KM)
            case .short:
                v = self.value * METERS_TO_YARDS * 3
            default:
                v = self.value * METERS_TO_YARDS
            }
        }
        return v
    }
    
    // MARK: - Full String Display Methods
    func displayValue(_ scale:DistanceScale, precision:Int, plusOrMinus: Bool = false) -> String{
        let value = calcValue(scale)
        return plusOrMinus ? String(format: "%@%.\(precision)f", (value > 0 ? "+" : ""), value) : String(format: "%.\(precision)f", value)
    }
    
    func displayValue(_ scale:DistanceScale, precision:Int, forceMetric : Bool = false, plusOrMinus: Bool = false) -> String{
        
        let value = forceMetric ? metersValue : calcValue(scale)
        return plusOrMinus ? String(format: "%@%.\(precision)f", (value > 0 ? "+" : ""), value) : String(format: "%.\(precision)f", value)
    }
    
    func displayUnit(_ scale:DistanceScale, abbreviated:Bool, capitalized:Bool) -> String {
        
        // Helper
        func p(_ s:String) -> String{
            if scale == .short && !useMetric {
                return self.value != 1 ? NSLocalizedString("feet",comment: "unit of measurement") : s
            }
            return self.value != 1 ? String.localizedStringWithFormat(NSLocalizedString("%@s", comment: "the last 's' will get translated. This is strictly for pluralizing. The end result may be something like 'yds'"), s) : s
        }
        
        var s:String
        if useJapanese {
            switch scale {
            case .long:
                s = abbreviated ? p(NSLocalizedString("yd", comment:"abreviation for 'yard'; measurement")) : p(NSLocalizedString("yard", comment: "measurement"))
            case .short:
                s = abbreviated ? NSLocalizedString("m", comment:"abreviation for meter" ): p(NSLocalizedString("meter", comment: ""))
            default:
                s = abbreviated ? p(NSLocalizedString("yd", comment:"abreviation for 'yard'; measurement")) : p(NSLocalizedString("yard", comment: "measurement"))
            }
        }
        else if useMetric {
            switch scale {
            case .long: s = NSLocalizedString("km", comment: "abbreviation for kilometer")
            default: s = abbreviated ? NSLocalizedString("m", comment:"abreviation for meter" ): p(NSLocalizedString("meter", comment: ""))
            }
        } else {
            switch scale {
            case .long: s = abbreviated ? NSLocalizedString("mi", comment:"abreviation for mile") : p(NSLocalizedString("mile", comment: ""))
            case .short: s = abbreviated ? NSLocalizedString("ft", comment: "abreviation for 'foot'; measurement") : p(NSLocalizedString("foot", comment:"measurement"))
            default: s = abbreviated ? p(NSLocalizedString("yd", comment:"abreviation for 'yard'; measurement")) : p(NSLocalizedString("yard", comment: "measurement"))
            }
        }
        
        if capitalized {
            s = s.capitalized
        }
        return s
    }
    
    func displayString(_ scale:DistanceScale, abbreviated:Bool, capitalized:Bool, precision:Int, plusOrMinus: Bool = false) -> String {
        
        let a = displayValue(scale, precision: precision, plusOrMinus: plusOrMinus)
        let b = displayUnit(scale, abbreviated:abbreviated, capitalized: capitalized)
        return "\(a) \(b)"
    }
    
    // MARK: - Helpers
    var useMetric:Bool {
        return false
    }
    var useJapanese:Bool {
        return false
    }
    
    // MARK: - NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.value, forKey: "value")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self.value = aDecoder.decodeDouble(forKey: "value")
    }
    
}

/**
 NOTE: These operator overloads will NOT be called in Objective-C code! Instead use greaterThan, lessThan, and isEqual methods provided.
 Reference: http://stackoverflow.com/questions/37682110/operator-overload-declared-in-swift-class-is-sometimes-not-called-when-used
 **/
func <(a:Distance, b:Distance) -> Bool {
    return a.value < b.value
}
func ==(a:Distance, b:Distance) -> Bool {
    return a.value == b.value
}

func +(a:Distance, b:Distance) -> Distance{
    return Distance(meters: a.value + b.value)
}


struct PlaysLikeAdjustments {
    static let kWindGustAdjustmentThreshholdInMeters : Double = 4.57
    
    var altitude : Double?
    var windAdjustment : Double?
    var windSpeedKMH : Double?
    var windSpeedMPH : Double?
    var windGust : Double?
    var windGustAdjustment : Double?
    var startElevation : Double?
    var endElevation : Double?
    var elevationChange : Double? {
        guard let sEl = startElevation, let eEL = endElevation else {return nil}
        return sEl - eEL
    }
    var elevationChangeAdjustment : Double?
    var humidity : Double?
    var humidityAdjustment : Double?
    var temperature : Double?
    var temperatureAdjustment : Double?
    var altitudeAdjustment : Double?
    var actualDistance : Double
    var playsLikeDistance : Double
    var windDirection : Double?
    var holeBearing : Double?
    
    var addedUpTotal : Double? {
        var processed = rounded(num: actualDistance)
        processed += rounded(num: windAdjustment)
        processed += rounded(num: windGustAdjustment)
        processed += rounded(num: humidityAdjustment)
        processed += rounded(num: temperatureAdjustment)
        processed += rounded(num: elevationChangeAdjustment)
        processed += rounded(num: altitudeAdjustment)
        return processed
    }
    
    var addedUpTotalNoGust : Double? {
        var processed = rounded(num: actualDistance)
        processed += rounded(num: windAdjustment)
        processed += rounded(num: humidityAdjustment)
        processed += rounded(num: temperatureAdjustment)
        processed += rounded(num: elevationChangeAdjustment)
        processed += rounded(num: altitudeAdjustment)
        return processed
    }
    
    func rounded (num:Double?) -> Double {
        guard let num = num else {return 0}
        return round(Distance.init(meters: num).calcValue(.medium))
    }
    //Get clubs from the bag
    
}
