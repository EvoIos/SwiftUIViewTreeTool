
var uniqeIds: [Int] = []

final class TreeNode<T> {
    var id: Int = 0
    var value: T
    var left: TreeNode?
    var right: TreeNode?
    
    public init(value: T) {
        self.value = value
    }
}

func newNode<T>(data: T) -> TreeNode<T> {
    let node = TreeNode.init(value: data)
    if let last = uniqeIds.last {
        uniqeIds.append(last+1)
        node.id = uniqeIds.last!
    } else {
        uniqeIds.append(0)
        node.id = 0
    }
    node.left = nil
    node.right = nil
    return node
}

func preOrder<T>(node: TreeNode<T>?) {
    if node == nil {
        return
    }
    print("node: \(node!.value)")
    preOrder(node: node!.left)
    preOrder(node: node!.right)
}
