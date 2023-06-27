import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dio/dio.dart';

class Stape {
  static const _regex1 = r"&token=([^\s]*)\'\)";
  static final _dio = Dio()
    ..options = BaseOptions(
      receiveTimeout: 30000,
      sendTimeout: 30000,
      connectTimeout: 30000,
    );
  static const String _defaultUserAgent =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.131 Safari/537.36";
  static Future<String?> get(String url) async {
    return await _stapet1(url);
  }

  static Future<String?> _stapet1(String url) async {
    var response = await _getResponse(url);
    if (response == null) {
      return null;
    }
    var link = await _generateDownloadLink(response);
    return link;
  }

  static Future<String?> _generateDownloadLink(String response) async {
    String globalValue = "https:/";
    var bs = BeautifulSoup(response);
    var token = _getToken(bs);
    if (token == null) {
      return null;
    }
    var robotLinkElements = bs.find("*", id: "robotlink");
    if (robotLinkElements == null) {
      return null;
    }
    var link = robotLinkElements.text;
    link = link.substring(0, link.lastIndexOf("="));
    return "$globalValue$link=$token&stream=1";
  }

  static String? _getToken(BeautifulSoup bs) {
    var elements = bs.findAll("script");
    var pattern = RegExp(_regex1, multiLine: true);
    if (elements.join("").contains("&token=")) {
      var match = pattern.firstMatch(elements.toString());
      return match!.group(1);
    }
    return null;
  }

  static Future<String?> _getResponse(String url) async {
    String costumized = _customizeUrl(url);

    try {
      var res = await _dio.get<String>(
        costumized,
        options: Options(headers: _getHeaders(url)),
      );
      if (!(res.data?.contains("Video not found!") ?? true)) {
        return res.data;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  static String _getVideoId(String url) {
    return url.split("/")[4];
  }

  static Map<String, String> _getHeaders(String url) {
    return {
      "authority": "stape.fun",
      "method": "GET",
      "path": "/e/${_getVideoId(url)}",
      "referer": "https://streamtape.com/",
      "user-agent": _defaultUserAgent,
    };
  }

  static String _customizeUrl(String url) {
    if (url.contains("streamtape.com")) {
      url = url.replaceAll("streamtape.com", "stape.fun");
    }

    if (url.contains("/v/")) url = url.replaceAll("/v/", "/e/");

    return url;
  }
}
