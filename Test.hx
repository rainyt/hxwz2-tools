import haxe.Json;

@:access(ActBuilderAtlasDataParser)
class Test {
    
    static function main() {
        
        Sys.command("neko bin/actbuilder_parser.n indexFile/roledata/HeJin.data");
        // Sys.command("neko bin/actbuilder_atlas_parser.n out/role.data out/content.png HeJin");

    }

}