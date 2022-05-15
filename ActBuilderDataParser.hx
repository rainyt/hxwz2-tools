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
		rolePath = Sys.args()[0];
		outPath = Sys.args()[1];
		if (rolePath == null || outPath == null)
			throw "参数错误";
		trace("解析人物包：", rolePath);
		if (FileSystem.exists(outPath + "/role.data")) {
			Sys.command("rm -rf " + outPath);
		}
		FileSystem.createDirectory(outPath);
		var targetZipData = StringTools.replace(rolePath.substr(rolePath.lastIndexOf("/") + 1), ".data", ".zip");
		File.copy(rolePath, outPath + "/" + targetZipData);
		// 解压人物包
		Sys.setCwd(outPath);
		Sys.command("unzip " + targetZipData);
		// 解码操作
		decodeProcess(".");
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
