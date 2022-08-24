import CustomDump
import XCTest
@testable import XXClient

final class UDSearchResultTests: XCTestCase {
  func testCoding() throws {
    let idB64 = "pYIpRwPy+FnOkl5tndkG8RC93W/t5b1lszqPpMDynlUD"
    let facts: [Fact] = [
      Fact(fact: "carlos_arimateias", type: 0),
    ]
    let jsonString = """
    {
      "ID": "\(idB64)",
      "Facts": \(String(data: try! facts.encode(), encoding: .utf8)!)
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try UDSearchResult.decode(jsonData)

    XCTAssertNoDifference(model, UDSearchResult(
      id: Data(base64Encoded: idB64)!,
      facts: facts
    ))

    let encodedModel = try model.encode()
    let decodedModel = try UDSearchResult.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }

  func testCodingArray() throws {
    let models: [UDSearchResult] = [
      UDSearchResult(
        id: Data(base64Encoded: "pYIpRwPy+FnOkl5tndkG8RC93W/t5b1lszqPpMDynlUD")!,
        facts: [
          Fact(fact: "carlos_arimateias", type: 0),
        ]
      ),
    ]
    let encodedModels = try models.encode()
    let decodedModels = try [UDSearchResult].decode(encodedModels)

    XCTAssertNoDifference(decodedModels, models)
  }

  func testEncodeWithBigInt() throws {
    let idB64 = "pYIpRwPy+FnOkl5tndkG8RC93W/t5b1lszqPpMDynlUD"
    let facts: [Fact] = [
      Fact(fact: "carlos_arimateias", type: 0),
    ]
    let jsonString = """
    {
      "ID": "\(idB64)",
      "DhPubKey": {
        "Value": 1759426033802606996617132861414734059978289057332806031357800676138355264622676606691435603603751978195460163638145821347601916259127578968570412642641025630452893097179266022832268525346700655861033031712000288680395716922501450233258587788020541937373196899001184700899008948530359980753630443486308876999029238453979779103124291315202352475056237021681172884599194016245219278368648568458514708567045834427853469072638665888791358582182353417065794210125797368093469194927663862565508608719835557592421245749381164023134450699040591219966988201315627676532245052123725278573237006510683695959381015415110970848376498637637944431576313526294020390694483472829278364602405292767170719547347485307956614210210673321959886410245334772057212077704024337636501108566655549055129066343309591274727538343075929837698653965640646190405582788894021694347212874155979958144038307500444865955516612526623220973497735316081265793063949,
        "Fingerprint": 15989433043166758754
      },
      "OwnershipProof": null,
      "Facts": \(String(data: try! facts.encode(), encoding: .utf8)!)
    }
    """
    let jsonData = jsonString.data(using: .utf8)!

    let decodedModel = try UDSearchResult.decode(jsonData)

    XCTAssertNoDifference(decodedModel, UDSearchResult(
      id: Data(base64Encoded: idB64)!,
      facts: facts
    ))
  }
}
