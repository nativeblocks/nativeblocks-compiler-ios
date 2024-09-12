import Foundation

struct TypeUtils {
    static func typeMapToJson(_ type: String) -> String? {
        switch type.uppercased() {
        case "STRING":
            return "STRING"
        case "INT", "INT32", "INT16", "INT8", "UINT", "UINT32", "UINT16", "UINT8":
            return "INT"
        case "INT64", "UINT64":
            return "LONG"
        case "FLOAT", "FLOAT80", "FLOAT64", "FLOAT32", "FLOAT16":
            return "FLOAT"
        case "DOUBLE", "CGFLOAT":
            return "DOUBLE"
        case "BOOL":
            return  "BOOLEAN"
        default:
            return nil
        }
    }
    
    static func thenMapToJson(_ then: String?) -> String {
        switch then?.uppercased() {
        case "SUCCESS":
            return "SUCCESS"
        case "FAILURE":
            return "FAILURE"
        case "NEXT":
            return "NEXT"
        case "END":
            return "END"
        default:
            return "END"
        }
    }
}
