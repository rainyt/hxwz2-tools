import sys.FileSystem;

class ParserActBuilderData {
	static function main() {
		var dir = "indexFile/roledata";
		var files = FileSystem.readDirectory(dir);
		for (index => value in files) {
			parserRole(dir + "/" + value);
		}
	}

	/**
	 * 解析角色
	 * @param path 
	 */
	private static function parserRole(path:String):Void {
		trace("开始解析：", path);
		var name = path.substr(path.lastIndexOf("/") + 1);
		name = name.substr(0, name.lastIndexOf("."));
		Sys.command("neko bin/actbuilder_parser.n " + path + " Out/" + name + "_AB");
	}
}
