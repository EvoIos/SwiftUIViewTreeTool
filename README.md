# SwiftUIViewTreeTool

用来将 SwiftUI view tree 结构格式化的工具。

例如 view tree: 

```
VStack<TupleView<(ModifiedContent<ModifiedContent<ModifiedContent<ModifiedContent<Text, _PaddingLayout>, _BackgroundModifier<Color>>, _ClipEffect<RoundedRectangle>>, AddGestureModifier<_EndedGesture<TapGesture>>>, _ConditionalContent<Text, Text>)>>
```

格式化成树形图：


![stack view tree](https://github.com/EvoIos/SwiftUIViewTreeTool/blob/master/snapshots/SwiftUIStackTree.png)

## 安装

依赖 GraphViz

```
brew install graphviz
```
