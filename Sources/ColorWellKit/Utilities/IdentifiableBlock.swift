//
//  IdentifiableBlock.swift
//  ColorWellKit
//

private func _nextBlockIdentifier() -> UInt64 {
    enum Context {
        static var identifier: UInt64 = 0
    }
    defer {
        Context.identifier += 1
    }
    return Context.identifier
}

/// An identifier for a block.
struct BlockIdentifier: Hashable {
    private let rawValue: UInt64

    /// Creates a unique block identifier.
    init() {
        self.rawValue = _nextBlockIdentifier()
    }
}

/// A block that is identified by a `BlockIdentifier`.
protocol IdentifiableBlock: Hashable {
    /// The input type of the block.
    associatedtype Input
    /// The output type of the block.
    associatedtype Output

    /// The identifying element of the block.
    var identifier: BlockIdentifier { get }
    /// The body of the block.
    var body: (Input) -> Output { get }

    /// Creates a block with the given identifier and body.
    init(identifier: BlockIdentifier, body: @escaping (Input) -> Output)
}

extension IdentifiableBlock {
    /// Creates a block with the given body.
    init(body: @escaping (Input) -> Output) {
        self.init(identifier: BlockIdentifier(), body: body)
    }

    /// Calls the block.
    func callAsFunction(_ input: Input) -> Output {
        body(input)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
