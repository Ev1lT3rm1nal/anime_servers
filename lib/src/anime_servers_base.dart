import 'package:anime_servers/src/servers/zippyshare.dart';
import 'package:animeflv/models/server_info.dart';

import 'servers/stape.dart';

class AnimeServers {
  static Future<String?> _getVideoLink(String url, String server) async {
    switch (server) {
      case "Zippyshare":
        return await Zippyshare.get(url);
      case "Stape":
        return await Stape.get(url);
      default:
    }
    return null;
  }

  static Future<List<ServerInfo>> getVideoLinks(
      List<ServerInfo> servers) async {
    var links = <ServerInfo>[];
    for (var server in servers) {
      var link = await _getVideoLink(server.url, server.server);
      if (link != null) {
        links.add(ServerInfo(link, server.server));
      }
    }
    return links;
  }
}
