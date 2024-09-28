import sys.FileStat;
import haxe.io.Path;
import haxe.Exception;
import haxe.zip.Reader;
import haxe.io.Bytes;
import openfl.utils.ByteArray;
import haxe.Int64;
import sys.io.File;
import sys.FileSystem;

/**
 * ActBuilder工具生成的加密人物包解析器
 */
class ActBuilderDataParser {
	/**
	 * AB数据包路径
	 */
	public static var rolePath:String;

	/**
	 * 输出文件夹
	 */
	public static var outPath:String;

	static function main() {
		#if cpp
		rolePath = Sys.args()[1];
		outPath = Sys.args()[2];
		#else
		rolePath = Sys.args()[0];
		outPath = Sys.args()[1];
		#end
		if (rolePath == null || outPath == null)
			throw "args error:" + Sys.args();
		trace("parser role data:", rolePath);
		if (FileSystem.exists(outPath + "/role.data")) {
			Sys.command("rm -rf " + outPath);
		}
		FileSystem.createDirectory(outPath);
		var targetZipData = StringTools.replace(rolePath.substr(rolePath.lastIndexOf("/") + 1), ".data", ".zip");
		File.copy(rolePath, outPath + "/" + targetZipData);
		// 解压人物包
		Sys.setCwd(outPath);
		var zip = new Reader(File.read(targetZipData));
		var list = zip.read();
		for (item in list.iterator()) {
			trace("unzip:", item.fileName);
			if (item.fileName.indexOf("/") != -1) {
				var dir = item.fileName.substr(0, item.fileName.lastIndexOf("/"));
				if (!FileSystem.exists(dir))
					FileSystem.createDirectory(dir);
			}
			try {
				if (item.compressed) {
					var newBytes = Reader.unzip(item);
					File.saveBytes(item.fileName, newBytes);
				} else
					File.saveBytes(item.fileName, item.data);
			} catch (e:Exception) {
				trace("Error:", e.message);
			}
		}
		// Sys.command("unzip " + targetZipData);
		// 解码操作
		decodeProcess(".");

		// 将role.data转换为对应的zyproject文件
		exportZyproject("role.data", Path.withoutDirectory(rolePath));
	}

	static function exportZyproject(file:String, name:String):Void {
		var save = Path.withoutExtension(Path.withoutDirectory(name)) + ".zyproject";
		File.copy(file, save);
		FileSystem.deleteFile(file);
		// 然后这里需要读取zyproject的path参数，然后读取到png和xml
		var xml:Xml = Xml.parse(File.getContent(save));
		var path = xml.firstElement().get("path");
		var pngPath = Path.withoutExtension(Path.withoutDirectory(path)) + ".png";
		FileSystem.rename("./content.png", pngPath);
		var atlas:Xml = Xml.createDocument();
		var root:Xml = Xml.createElement("TextureAtlas");
		root.set("imagePath", pngPath);
		atlas.insertChild(root, 0);
		for (item in xml.firstElement().elements()) {
			if (item.nodeName == "act") {
				for (sub in item.elements()) {
					root.insertChild(sub, 0);
				}
			}
		}
		File.saveContent(Path.withoutExtension(Path.withoutDirectory(path)) + ".xml", atlas.toString());
		trace("path=", path);
	}

	static function decodeProcess(dir:String):Void {
		var files = FileSystem.readDirectory(dir);
		for (index => value in files) {
			var path = dir + "/" + value;
			if (FileSystem.isDirectory(path)) {
				decodeProcess(path);
			} else {
				var t = value.substr(value.lastIndexOf(".") + 1);
				var bytes = decode(path);
				switch (t) {
					case "xml", "data":
						// 文本XML解码
						var content = bytes.readUTFBytes(bytes.bytesAvailable);
						trace("解码后：", content);
						File.saveContent(path, content);
					case "mp3", "png":
						// 图片和音频解析
						File.saveBytes(path, bytes);
				}
			}
		}
	}

	public static function decode(path:String):ByteArray {
		trace("decode", path);
		var rootBytes = File.getBytes(path);
		var code:Int64 = Int64.fromFloat(99390298351126);
		var newBytes:Bytes = Bytes.alloc(rootBytes.length);
		for (i in 0...rootBytes.length) {
			var i64 = Int64.fromFloat(rootBytes.get(i)) - code;
			newBytes.setInt64(i, i64);
		}
		var b = ByteArray.fromBytes(newBytes);
		return b;
	}
}
