//
//  ContentView.swift
//  SwiftUIViewTreeTool
//
//  Created by zlc on 2020/6/4.
//  Copyright © 2020 open.tool.app. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State var viewTree: String = "ViewTree"
    
    @State var counter = 0

    @State var nsImage: NSImage? = nil
    
    var body: some View {

        // Text
//        let v = Text("example text").frame(maxWidth: 300)
        
        // stack
        let v = VStack(spacing: 10) {
            Text("Tap me!")
                .padding()
                .background(Color(.tertiaryLabelColor))
                .cornerRadius(5)
                .onTapGesture {
                    self.counter += 1
            }
            
            if self.counter > 0 {
                Text("You've tapped \(counter) times")
            } else {
                Text("You've not yet tapped")
            }
        }
        
        return VStack(spacing: 0) {
            Text("Show View Tree")
                .font(.largeTitle)
                .frame(maxHeight: 50)
                .padding([.top,.bottom], 20)
                .onTapGesture {
                    let subjectInfo = v.subjectTypeInfo()
                    print("subjectInfo: \(subjectInfo)")
                    self.viewTree = subjectInfo
                    self.nsImage = self.graphImage(subjectInfo)
            }
            
            Divider()
            
            HStack(spacing: 0) {
                v
                Divider()
                Text(self.viewTree)
                    .font(.title)
                    .padding(8)
                    .layoutPriority(1)
                    .frame(minWidth: 350)
                Divider()
                VStack {
                    Group {
                        if nsImage != nil {
                            Image(nsImage: nsImage!)
                        } else {
                            Text("no Image")
                        }
                    }
                }
                .layoutPriority(2)
                .frame(minWidth: 325)
                Spacer().frame(width: 20)
            }
        }
        .frame(minWidth: 1024, minHeight: 768)
    }
}

// MARK: - render image
extension ContentView {
    func handleInput(_ inputText: String) -> [String] {
        var input = inputText
        
        let index = input.firstIndex { e -> Bool in
            return e == "("
        }
        
        if let index = index {
            input.insert(contentsOf: "Tuple", at: index)
        }
        
        
        input = input
            // 针对元组情况
            .replacingOccurrences(of: "(", with: "<")
            .replacingOccurrences(of: ")", with: ">")
            // 替换为（）
            .replacingOccurrences(of: "<", with: "(")
            .replacingOccurrences(of: ">", with: ")")
            .replacingOccurrences(of: ",", with: ")(")
        
        var strs: [String] = []
        var group: [String] = []
        for str in Array(input) {
            switch str {
            case " ": continue
            case "(", ")": // 单独成组
                if group.count > 0 {
                    strs.append(group.reduce("",+))
                    group.removeAll()
                }
                strs.append(String(str))
            default:
                group.append(String(str))
            }
        }
        
        return strs
    }
    
    func findIndex(strs: [String], si: Int, ei: Int) -> Int {
        if si > ei {
            return -1
        }
        
        var myStack = Stack<String>()
        
        for idx in (si...ei) {
            let value = strs[idx]
            if value == "(" {
                myStack.push(String(value))
            } else if value == ")" {
                if (myStack.top ?? "") == "(" {
                    myStack.pop()
                    
                    if myStack.isEmpty {
                        return idx
                    }
                }
            }
        }
        return -1
    }
    
    func treeFromString(strs: [String], si: Int, ei: Int) -> TreeNode<String>? {
        if (si > ei) || strs.isEmpty {
            return nil
        }
        
        let root: TreeNode = newNode(data: strs[si])
        var index = -1
        
        if si+1 <= ei && strs[si+1] == "(" {
            index = findIndex(strs: strs, si: si + 1, ei: ei)
        }
        
        if index != -1 {
            root.left = treeFromString(strs: strs, si: si+2, ei: index - 1)
            root.right = treeFromString(strs: strs, si: index + 2, ei: ei - 1)
        }
        return root
    }
    
    func treeToGraph(nodeString: inout String, edgeString: inout String, node: TreeNode<String>?) {
        if node == nil {
            return
        }
           
        let root = DotRender.createNodeCode(idx: node!.id) + " " + DotRender.createNodeLabel(node!.value) + "\n"
        nodeString += root
        
        if node!.left != nil {
            let left = DotRender.createNodeCode(idx: node!.left!.id) + " " + DotRender.createNodeLabel(node!.value) + "\n"
            nodeString += left
            
            let leftEdge = DotRender.createEdge(from: DotRender.createNodeCode(idx: node!.id), to: DotRender.createNodeCode(idx: node!.left!.id))
            edgeString += leftEdge
        }
        if node!.right != nil {
            let right = DotRender.createNodeCode(idx: node!.right!.id) + " " + DotRender.createNodeLabel(node!.value) + "\n"
            nodeString += right
                       
            let rightEdge = DotRender.createEdge(from: DotRender.createNodeCode(idx: node!.id), to: DotRender.createNodeCode(idx: node!.right!.id))
            edgeString += rightEdge
        }
           
        treeToGraph(nodeString: &nodeString, edgeString: &edgeString, node: node!.left)
        treeToGraph(nodeString: &nodeString, edgeString: &edgeString, node: node!.right)
    }
    
    func graphImage(_ input: String) -> NSImage? {
        
        let strs = handleInput(input)
        let root = treeFromString(strs: strs, si: 0, ei: strs.count)
            
        var nodeString = ""
        var edgeString = ""
        treeToGraph(nodeString: &nodeString, edgeString: &edgeString, node: root)
        
        let dot = DotRender.render(node: nodeString, edge: edgeString)
        
        if nodeString.isEmpty && edgeString.isEmpty {
            return nil
        }
        
        print("dot:\n\(dot)")
        
        do {
            let data = try DotRender.render(encoded: dot, to: .png)
            let nsImage = NSImage.init(dataIgnoringOrientation: data)
            return nsImage
        }
        catch {
            return nil
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

