import haxe.Json;

@:access(ActBuilderAtlasDataParser)
class Test {
    
    static function main() {
        
        Sys.command("neko bin/actbuilder_parser.n test/XiaoWu.data ./out");
        // Sys.command("neko bin/actbuilder_atlas_parser.n out/role.data out/content.png HeJin");

    }

}