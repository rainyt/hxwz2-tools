import haxe.zip.Entry;
import haxe.zip.Writer;
import sys.FileSystem;
import openfl.utils.ByteArray;
import haxe.io.Bytes;
import haxe.Int64;
import sys.io.File;

/**
 * 对ActBuilderData进行加密处理
 */
class ActBuilderDataEncode {
	static function main() {
		var path = Sys.args()[0];
		path = StringTools.replace(path, "\\", "/");
		if (FileSystem.exists(path + "/content.png") && FileSystem.exists(path + "/role.data")) {
			var files = FileSystem.readDirectory(path);
			if (!FileSystem.exists(path + "/bin")) {
				FileSystem.createDirectory(path + "/bin");
			}
			var name = path.substr(path.lastIndexOf("/") + 1);
			name = StringTools.replace(name, "_AB", "");
			var savePath = path + "/bin/" + name + ".data";
			// 打开一个压缩实现
			var out = File.write(savePath);
			var zip = new Writer(out);
			var list:List<haxe.zip.Entry> = new List();
			for (file in files) {
				// 忽略生成目录
				if (file == "bin")
					continue;
				if (file == "audit.xml" || file == "content.png" || file == "effect" || file == "sound")
					writeZipEntry(path + "/" + file, file, list);
			}
			zip.write(list);
			File.saveBytes(savePath, encode(savePath));
			trace("生成完成");
		} else {
			// 当前目录不存在有效的人物数据
			throw "不存在有效的content.png、role.data数据";
		}
	}

	/**
	 * 写入到zip目录下
	 * @param path 
	 * @param list 
	 */
	public static function writeZipEntry(path:String, zipFileName:String, list:List<Entry>):Void {
		trace("write:", path);
		if (FileSystem.isDirectory(path)) {
			var files = FileSystem.readDirectory(path);
			for (file in files) {
				writeZipEntry(path + "/" + file, zipFileName + "/" + file, list);
			}
		} else {
			var bytes = encode(path);
			list.add({
				fileName: zipFileName,
				fileSize: 1,
				fileTime: Date.now(),
				compressed: false,
				dataSize: bytes.length,
				data: bytes,
				crc32: 0
			});
		}
	}

	/**
	 * 加密程序
	 * @param path 
	 * @return ByteArray
	 */
	public static function encode(path:String):ByteArray {
		var rootBytes = File.getBytes(path);
		var code:Int64 = Int64.fromFloat(99390298351126);
		var newBytes:Bytes = Bytes.alloc(rootBytes.length);
		for (i in 0...rootBytes.length) {
			var i64 = Int64.fromFloat(rootBytes.get(i)) + code;
			newBytes.setInt64(i, i64);
		}
		var b = ByteArray.fromBytes(newBytes);
		return b;
	}
}
