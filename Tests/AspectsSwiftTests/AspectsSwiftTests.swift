import Aspects
import Foundation
import XCTest

@objcMembers
final class SwiftHookTarget: NSObject {
    private(set) var originalCallCount = 0

    dynamic func sendEvent(_ event: NSObject) {
        originalCallCount += 1
    }
}

final class AspectsSwiftTests: XCTestCase {
    func testDirectSwiftClosureReturnsMissingSignatureError() {
        let target = SwiftHookTarget()

        XCTAssertThrowsError(
            try target.aspect_hook(
                NSSelectorFromString("sendEvent:"),
                with: .positionInstead,
                usingBlock: { (_: AspectInfo) in }
            )
        ) { error in
            let error = error as NSError
            XCTAssertEqual(error.domain, AspectErrorDomain)
            XCTAssertEqual(error.code, Int(AspectErrorCode.missingBlockSignature.rawValue))
        }
    }

    func testObjCBlockConventionCanHookFromSwift() throws {
        let target = SwiftHookTarget()
        var didInvokeAspect = false

        let block: @convention(block) (AspectInfo) -> Void = { info in
            didInvokeAspect = true
            XCTAssertEqual(info.arguments()?.count, 1)
            info.originalInvocation().invoke()
        }

        let token = try XCTUnwrap(
            try target.aspect_hook(
                NSSelectorFromString("sendEvent:"),
                with: .positionInstead,
                usingBlock: block
            )
        )

        target.sendEvent(NSObject())
        XCTAssertTrue(didInvokeAspect)
        XCTAssertEqual(target.originalCallCount, 1)
        XCTAssertTrue(token.remove())
    }

    func testSwiftInfoBlockConvenienceCanHookWithPlainClosure() throws {
        let target = SwiftHookTarget()
        let event = NSObject()
        var capturedEvent: NSObject?

        let token = try XCTUnwrap(
            try target.aspect_hook(
                NSSelectorFromString("sendEvent:"),
                with: .positionInstead
            ) { info in
                capturedEvent = info.arguments()?.first as? NSObject
                info.originalInvocation().invoke()
            }
        )

        target.sendEvent(event)
        XCTAssertIdentical(capturedEvent, event)
        XCTAssertEqual(target.originalCallCount, 1)
        XCTAssertTrue(token.remove())
    }
}
