package;

import haxe.Exception;
import haxe.Json;
import haxe.crypto.Md5;
import sys.FileSystem;
import sys.io.File;

/**
 * 解析精灵图，需要提供一个data原始数据，以及一个图片
 */
class ActBuilderAtlasDataParser {
	public static var saveTag:String;

	public static var outPath:String;

	public static var dirPath:String;

	static function main() {
		dirPath = Sys.args()[0];
		outPath = Sys.args()[1];
		var xmlPath = dirPath + "/role.data";
		var pngPath = dirPath + "/content.png";
		saveTag = dirPath.substr(dirPath.lastIndexOf("/") + 1);
		saveTag = saveTag.substr(0, saveTag.lastIndexOf("_"));
		trace("解析精灵图：" + xmlPath, pngPath, saveTag, outPath);

		var roleXml:Xml = Xml.createDocument();
		var roleRoot:Xml = Xml.createElement("Role");
		roleRoot.set("type", "sprite");
		roleXml.addChild(roleRoot);
		var contentRoot:Xml = Xml.createElement("content");
		roleRoot.addChild(contentRoot);
		var loadsRoot:Xml = Xml.createElement("loads");
		roleRoot.addChild(loadsRoot);
		var actionRoot:Xml = Xml.createElement("action");
		roleRoot.addChild(actionRoot);

		var atlasXml:Xml = Xml.createDocument();
		var atlasRoot:Xml = Xml.createElement("TextureAtlas");
		atlasXml.addChild(atlasRoot);
		atlasRoot.set("imagePath", saveTag + ".png");

		var xmlFile = Xml.createElement("xml");
		xmlFile.set("path", "npc/" + saveTag + ".xml");
		var pngFile = Xml.createElement("image");
		pngFile.set("path", "npc/" + saveTag + ".png");
		contentRoot.addChild(xmlFile);
		contentRoot.addChild(pngFile);

		var data = File.getContent(xmlPath);
		var xml = Xml.parse(data);
		var md5Name = [];
		atlasRoot.set("px", xml.firstElement().get("px"));
		atlasRoot.set("py", xml.firstElement().get("py"));
		for (item in xml.firstElement().elements()) {
			switch (item.nodeName) {
				case "act":
					var act:Xml = Xml.createElement("act");
					// 技能名
					act.set("name", item.get("name"));
					// 键控
					act.set("key", parserKey(item.get("left"), item.get("right")));
					// 技能类型
					act.set("type", parserSkillType(item));
					// CD
					act.set("cd", item.get("cd"));
					// fps
					act.set("fps", parserFps(item.get("fps")));
					// 简介
					act.set("msg", item.get("tips"));
					actionRoot.addChild(act);
					// 解析精灵图
					for (atlas in item.elements()) {
						// 建立战斗数据的基础数据
						var frame = Xml.createElement("SubTexture");
						// 帧名称
						frame.set("name", atlas.get("name"));
						// 位移数据
						frame.set("gox", atlas.get("gox"));
						frame.set("goy", atlas.get("goy"));
						// 位移点
						frame.set("isApplyGoPoint", atlas.get("isApplyGoPoint"));
						// 特效列表effects
						frame.set("effects", parserEffects(loadsRoot, atlas.get("effects")));
						// 音效
						var soundName = StringTools.replace(atlas.get("soundName"), ".mp3", "");
						if (soundName != "" && soundName != null) {
							frame.set("soundName", saveTag + "_AB/" + soundName);
							// 将资源写入到loads中
							wirteLoads(loadsRoot, atlas.get("soundName"), "mp3");
						}
						act.addChild(frame);

						// 建立精灵单帧的基础数据
						var newAtlas = Xml.createElement("SubTexture");
						newAtlas.set("x", atlas.get("x"));
						newAtlas.set("y", atlas.get("y"));
						newAtlas.set("width", atlas.get("width"));
						newAtlas.set("height", atlas.get("height"));
						if (atlas.exists("frameX"))
							newAtlas.set("frameX", atlas.get("frameX"));
						if (atlas.exists("frameY"))
							newAtlas.set("frameY", atlas.get("frameY"));
						if (atlas.exists("frameWidth"))
							newAtlas.set("frameWidth", atlas.get("frameWidth"));
						if (atlas.exists("frameHeight"))
							newAtlas.set("frameHeight", atlas.get("frameHeight"));
						// 建立唯一码
						var md5 = atlas.get("name");
						if (md5Name.indexOf(md5) == -1) {
							md5Name.push(md5);
							newAtlas.set("name", md5);
							atlasRoot.addChild(newAtlas);
						}
					}
			}
		}
		if (!FileSystem.exists(outPath + "/npc"))
			FileSystem.createDirectory(outPath + "/npc");
		if (!FileSystem.exists(outPath + "/role"))
			FileSystem.createDirectory(outPath + "/role");
		File.saveContent(outPath + "/npc/" + saveTag + ".xml", atlasXml.toString());
		File.copy(pngPath, outPath + "/npc/" + saveTag + ".png");
		File.saveContent(outPath + "/role/" + saveTag + ".xml", roleXml.toString());
		File.saveContent(outPath + "/role/" + saveTag + ".data", roleXml.toString());
	}

	/**
		* AB的数据格式
		* this.name = data.tag;
		this.findName = data.findName;
		this.gox = data.gox != null ? data.gox : 0;
		this.goy = data.goy != null ? data.goy : 0;
		this.time = data.time != null ? data.time : 0;
		this.unhit = data.unhit != null ? data.unhit : false;
		this.isFollow = data.isFollow != null ? data.isFollow : false;
		this.isLockActionShow = data.isLockActionShow != null ? data.isLockActionShow : false;
		this.atbottom = data.atbottom != null ? data.atbottom : false;
		this.isABlow = data.isABlow != null ? data.isABlow : false;
		this.fadeIn = data.fadeIn != null ? data.fadeIn : false;
		this.blendMode = data.blendMode != null ? data.blendMode : "screen";
		* @param effects 
		* @return String
	 */
	private static function parserEffects(loads:Xml, effects:String):String {
		var a:Array<Dynamic> = Json.parse(effects);
		var newarray = [];
		for (index => value in a) {
			value = Json.parse(value);
			newarray.push({
				name: value.name,
				findName: value.findName,
				gox: value.gox,
				goy: value.goy,
				time: value.time,
				unhit: false,
				isFollow: value.isFollow,
				isLockActionShow: value.isLockAction,
				atbottom: false,
				isABlow: false,
				fadeIn: false,
				blow: value.blow,
				cardFrame: value.blow ? 8 : 0,
				blendMode: value.blendMode,
				x: value.x,
				y: value.y,
				scaleX: value.scaleX,
				scaleY: value.scaleY,
				fps: parserFps(Std.string(value.fps)),
				stiff: value.stiff,
				hitX: Std.int(value.hitX * 1.3),
				hitY: Std.int(value.hitY * 1.3),
				rotation: value.rotation
			});
		}
		for (index => value in newarray) {
			// 拷贝资源
			wirteLoads(loads, value.name, "sprites");
		}
		var newarray2 = [];
		for (index => value in newarray) {
			value.name = saveTag + "_AB/" + value.name;
			newarray2.push(Json.stringify(value));
		}
		return Json.stringify(newarray2);
	}

	/**
	 * 将资源写入到loads中
	 * @param loads 
	 * @param assetsPath 
	 * @param type mp3音频 sprites精灵图
	 */
	private static function wirteLoads(loads:Xml, assetsPath:String, type:String):Void {
		try {
			switch (type) {
				case "sprites":
					// 精灵表
					var atlas = Xml.createElement("sprites");
					var path = "effect/" + saveTag + "_AB/";
					if (!FileSystem.exists(outPath + "/" + path))
						FileSystem.createDirectory(outPath + "/" + path);
					path += assetsPath;
					atlas.set("path", path);
					path = outPath + "/" + path;
					var saveDir = dirPath + "/effect/" + assetsPath + ".xml";
					if (!FileSystem.exists(saveDir)) {
						var xmlContent = Xml.parse(File.getContent(saveDir));
						File.copy(dirPath + "/effect/" + assetsPath + ".png", path + ".png");
						xmlContent.firstElement().set("imagePath", path.substr(path.lastIndexOf("/") + 1) + ".png");
						File.saveContent(path + ".xml", xmlContent.toString());
					}
					loads.addChild(atlas);
				case "mp3":
					// 音频
					var sound = Xml.createElement("file");
					var dir = outPath + "/sound/" + saveTag + "_AB/";
					if (!FileSystem.exists(dir))
						FileSystem.createDirectory(dir);
					File.copy(dirPath + "/sound/" + assetsPath, dir + assetsPath);
					sound.set("path", StringTools.replace(dir, outPath + "/", "") + assetsPath);
					loads.addChild(sound);
			}
		} catch (e:Exception) {
			trace("Skin", assetsPath);
		}
	}

	/**
	 * 解析键控
	 * @param left 
	 * @param right 
	 * @return String
	 */
	private static function parserKey(left:String, right:String):String {
		var key = "";
		switch (left) {
			case "↑":
				key += "W";
			case "↓":
				key += "S";
			case "←":
				key += "A";
			case "→":
				key += "D";
		}
		key += right;
		return key;
	}

	/**
	 * 解析技能类型
	 * @param xml 
	 * @return String
	 */
	private static function parserSkillType(xml:Xml):String {
		var isAirSkill = xml.get("isAirSkill") == "true";
		var isIgnoreInjured = xml.get("isIgnoreInjured") == "true";
		// if(isIgnoreInjured){

		// }
		if (isAirSkill) {
			return "air";
		}
		return "land";
	}

	/**
	 * 解析FPS
	 * @param xml 
	 * @return String
	 */
	private static function parserFps(fps:String):String {
		if (fps == null)
			return "24";
		var fps = Std.parseInt(fps);
		if (fps <= 0 || fps == null)
			return "24";
		fps = Std.int(1 / fps * 24);
		return Std.string(fps);
	}
}
