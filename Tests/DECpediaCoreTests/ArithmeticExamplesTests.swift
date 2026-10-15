import XCTest

/// Independent finite checks for the worked examples printed in the bilingual catalog.
final class ArithmeticExamplesTests: XCTestCase {
    private func mod(_ x: Int, _ n: Int) -> Int { (x % n + n) % n }
    private func power(_ a: Int, _ exponent: Int, _ n: Int) -> Int {
        var a = mod(a,n), e = exponent, r = 1
        while e > 0 { if e % 2 == 1 { r = r*a % n }; a = a*a % n; e /= 2 }
        return r
    }
    func testRSASignaturesAndSourceSignConvention() {
        for (n,p,q,e,d,m,s) in [
            (403967,613,659,13,46465,101,297586),
            (304679,547,557,17,62501,102,33346),
            (304679,547,557,17,62501,103,144487),
            (875053,883,991,13,41047,104,537382)
        ] {
            XCTAssertEqual(p*q,n)
            XCTAssertEqual(power(m,d,n),s)
            XCTAssertEqual(power(s,e,n),m)
        }
        for (p,g,y,m,r,s,result) in [(457,13,369,101,209,328,450),(353,3,69,73,243,214,172),(199,44,132,81,148,123,67)] {
            XCTAssertEqual(power(r,s,p),result)
            XCTAssertEqual(power(g,m,p)*power(y,r,p)%p,result)
        }
        XCTAssertEqual(power(209,16,457),428)
        XCTAssertEqual(power(13,384,457)*power(345,209,457)%457,230)
        XCTAssertEqual(mod(power(3,21,31)*power(16,17,31)-power(17,27,31),31),29)
        XCTAssertEqual(mod(power(3,21,31)*power(26,13,31)-power(13,16,31),31),0)
    }
    private struct Point: Equatable { let x: Int; let y: Int }
    private func add(_ p: Point?, _ q: Point?) -> Point? {
        guard let p else { return q }; guard let q else { return p }
        if p.x == q.x && mod(p.y+q.y,37) == 0 { return nil }
        let numerator = p == q ? 3*p.x*p.x : q.y-p.y
        let denominator = mod(p == q ? 2*p.y : q.x-p.x,37)
        let slope = mod(numerator*power(denominator,35,37),37)
        let x = mod(slope*slope-p.x-q.x,37)
        return Point(x:x,y:mod(slope*(p.x-x)-p.y,37))
    }
    private func multiply(_ k: Int, _ p: Point) -> Point? {
        (0..<k).reduce(nil as Point?) { value,_ in add(value,p) }
    }
    func testAllThreeEllipticCurveDecryptions() {
        for (g,a,beta,c,message) in [
            (Point(x:4,y:19),7,Point(x:21,y:30),Point(x:33,y:14),Point(x:30,y:19) as Point?),
            (Point(x:3,y:18),5,Point(x:25,y:7),Point(x:25,y:7),nil),
            (Point(x:3,y:18),5,Point(x:25,y:7),Point(x:20,y:3),Point(x:33,y:23) as Point?)
        ] {
            XCTAssertEqual(multiply(3,g),beta)
            let shared = multiply(a,beta)!
            let recovered = add(c,Point(x:shared.x,y:mod(-shared.y,37)))
            XCTAssertEqual(recovered,message)
            XCTAssertEqual(add(recovered,shared),c)
            if let message { XCTAssertEqual(mod(message.y*message.y-message.x*message.x*message.x-1,37),0) }
        }
    }
    func testGolayGeneratorsByExhaustiveWeightEnumeration() {
        for (q,n,g,expected) in [
            (2,23,[1,1,0,0,0,1,1,1,0,1,0,1],[0:1,7:253,8:506,11:1288,12:1288,15:506,16:253,23:1]),
            (3,11,[2,2,1,2,0,1],[0:1,5:132,6:132,8:330,9:110,11:24])
        ] {
            let k = n-g.count+1
            let count = (0..<k).reduce(1) { r,_ in r*q }
            var weights: [Int:Int] = [:]
            for message in 0..<count {
                var digits = message, word = Array(repeating:0,count:n)
                for i in 0..<k {
                    let a = digits%q; digits /= q
                    for j in g.indices { word[i+j] = (word[i+j]+a*g[j])%q }
                }
                weights[word.filter { $0 != 0 }.count,default:0] += 1
            }
            XCTAssertEqual(weights,expected)
            var remainder = Array(repeating:0,count:n+1); remainder[0]=q-1; remainder[n]=1
            for degree in stride(from:n,through:g.count-1,by:-1) {
                let coefficient = remainder[degree]
                for j in g.indices { remainder[degree-g.count+1+j] = mod(remainder[degree-g.count+1+j]-coefficient*g[j],q) }
            }
            XCTAssertTrue(remainder.allSatisfy { $0 == 0 })
        }
    }
    private struct F9: Equatable {
        let a: Int, b: Int
        init(_ a: Int, _ b: Int = 0) { self.a=(a%3+3)%3; self.b=(b%3+3)%3 }
        static func + (x: Self,y: Self) -> Self { Self(x.a+y.a,x.b+y.b) }
        static func * (x: Self,y: Self) -> Self { Self(x.a*y.a-x.b*y.b,x.a*y.b+x.b*y.a) }
    }
    func testGF9ReedSolomonPolynomialAndCorrection() {
        let g = [F9(-1,-1),F9(-1),F9(1,1),F9(-1,1),F9(0,-1),F9(0,1),F9(1)]
        let h = [F9(-1,1),F9(0,-1),F9(1)]
        var product = Array(repeating:F9(0),count:9)
        for i in g.indices { for j in h.indices { product[i+j] = product[i+j] + g[i]*h[j] } }
        XCTAssertEqual(product,[F9(-1),F9(0),F9(0),F9(0),F9(0),F9(0),F9(0),F9(0),F9(1)])
        let word = g + [F9(0)]
        let reciprocal = Array(h.reversed())
        for shift in 0..<6 {
            let syndrome = reciprocal.indices.reduce(F9(0)) { $0 + reciprocal[$1]*word[shift+$1] }
            XCTAssertEqual(syndrome,F9(0))
        }
    }
}
