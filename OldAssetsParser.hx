package;

import sys.io.File;
import sys.FileSystem;

/**
 * 旧版资源解析，实现原理，由于已经实现好了一个ActBuilder的格式编译，因此，可以选择将旧资源升级到ActBuilder格式，然后进行统一解析。
 */
class OldAssetsParser {
	/**
	 * 运行例如：neko file.n indexFile/img Jianxin
	 */
	static function main() {
		var dir = "indexFile/img";
		var roleTag:String = Sys.args()[0];
		var out = "Out/" + roleTag + "_Old";
		if (!FileSystem.exists(out))
			FileSystem.createDirectory(out);
		// 人物精灵表拷贝
		File.copy(dir + "/role/" + roleTag + ".xml", out + "/role.data");
		File.copy(dir + "/role/" + roleTag + ".png", out + "/content.png");
		// 解析特效
		var xml:Xml = Xml.parse(File.getContent(out + "/role.data"));
        // xml.firstElement()
	}
}
