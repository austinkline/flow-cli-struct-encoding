access(all) contract Bar {
    access(all) struct B {
        access(all) let x: Int

        init(x: Int) {
            self.x = x
        }
    }
}