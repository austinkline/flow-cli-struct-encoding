import "Bar"

access(all) contract Foo {
    access(all) let B: Bar.B

    init(b: Bar.B) {
        self.B = b
    }
}