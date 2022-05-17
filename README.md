## 前置条件
请安装(Haxe环境)[http://haxe.org]。

## 已知问题
1、转换的工程暂未支持特效碰撞块自动识别。  
    原来的碰撞逻辑是使用像素级别碰撞，因此没有碰撞块，目前暂通过手动设置完成。

2、转换的工程特效重复。
    因为特效虽然是一样的，但配置可能不一样，避免冲突，则单个角色转换时会单独使用一份。

3、ActBuilder人物包转换出来的角色，音效、文件夹都会带_AB作为标示。

4、isFollow跟随角色的属性会失效。

5、卡帧、伤害等数据未完成同步，后续可能可以采取比例法，来还原伤害。

## 精灵图解码 ActBuilderAtlasDataParser
用于将data数据精灵图转换成常用的精灵图数据
```shell
neko actbuilder_atlas_parser.n '人物解码目录' '输出目录'
```

---

## Data人物包解码 ActBuilderDataParser
用于解码幻想纹章2系列的data加密数据，使用方法：
```shell
neko actbuilder_parser.n '人物数据.data' '输出目录'
```
##### 中文解决方案
注意，如果人物包存在中文，上面的方法在MacOS可以正常运行，但在Window上可能会失败，这种情况可使用cppia来解决问题：
```shell
haxelib install hxcpp
```
上面的库安装完毕后，则可以运行：
```shell
haxelib run hxcpp actbuilder_parser.cppia '人物数据.data' '输出目录'
```

---

## Data人物包加密 ActBuilderDataEncode
用于生成幻想纹章2系列的data加密数据，使用方法：
```shell
neko act_builder_data_encode.n '人物文件夹'
```
当生成成功后，在人物目录下会多一个`bin/人物文件夹.data`文件