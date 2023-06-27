import 'dart:math';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dio/dio.dart';

class Zippyshare {
  static const _regex1 = r"(\(\'dlbutton\'\)\.href = )(.*)(\;)";
  static const _regex2 = r'(\")(.*)(\/\"\ \+\ )(.*)(\ \+\ \")(.*)(\")';
  static const _regexa = r'var a = (.*);';
  static final _dio = Dio();

  static Future<String?> get(String url) async {
    return (await _zippyt1(url)) ?? await _zippyt2(url);
  }

  static Future<String?> _zippyt1(String url) async {
    Response<dynamic> response;
    try {
      response = await _dio.get(url);
    } catch (e) {
      return null;
    }
    var bs = BeautifulSoup(response.data);

    // get all script tags and sum them up
    var scripts = bs.findAll('script');
    var script = scripts.fold<String>(
      '',
      (acc, tag) => acc + tag.text,
    );

    // regex search for pattern 1
    var match1 = RegExp(_regex1).firstMatch(script);

    // check if pattern 1 is found
    if (match1 == null) {
      return null;
    }

    // get the second group of pattern 1
    var match2 = RegExp(_regex2).firstMatch(match1.group(2)!);

    // check if pattern 2 is found
    if (match2 == null) {
      return null;
    }

    // get the second group of pattern 2 and save it to a string variable
    var link = match2.group(2)!;

    // get the sixth group of pattern 2 and save it to a string variable
    var link2 = match2.group(6)!;

    // get the fourth group of pattern 2 and save it to a string variable
    // result will look like this: "(number1 % number2 + number3 % number4)
    // we need to solve this to get the correct link
    // first detect all numbers
    var numbers = RegExp(r'(\d+)').allMatches(match2.group(4)!);

    // create a list of numbers
    var list = <int>[];
    for (var i = 0; i < numbers.length; i++) {
      list.add(int.parse(numbers.elementAt(i).group(1)!));
    }

    // calculate the correct part of the link
    var link3 = (list[0] % list[1] + list[2] % list[3]);

    // sum up the link variables
    var finalPath = "$link/$link3$link2";

    // regrex replace pattern "/pd/" with "/d/" to get the direct link
    finalPath = finalPath.replaceAll("/pd/", "/d/");

    // get domain from url}
    var domain = url.split("/")[2];

    // return the direct link
    return "https://$domain$finalPath";
  }

  static Future<String?> _zippyt2(String url) async {
    Response<dynamic> response;
    try {
      response = await _dio.get(url);
    } catch (e) {
      return null;
    }
    var bs = BeautifulSoup(response.data);

    // get all script tags and sum them up
    var scripts = bs.findAll('script');
    var script = scripts.fold<String>(
      '',
      (acc, tag) => acc + tag.text,
    );

    // regex search for pattern 1
    var match1 = RegExp(_regex1).firstMatch(script);

    // check if pattern 1 is found
    if (match1 == null) {
      return null;
    }

    var aScript = scripts
        .where((element) =>
            element.innerHtml
                .contains("document.getElementById('dlbutton').omg") &&
            element.innerHtml.contains("var a = "))
        .first;

    var aMatch = RegExp(_regexa).firstMatch(aScript.text);

    if (aMatch == null) {
      return null;
    }

    var a = aMatch.group(1);

    // get the second group of pattern 1
    var file = match1.group(2)?.split("/").last;

    // check if pattern 2 is found
    if (file == null) {
      return null;
    }

    var route = match1
        .group(2)!
        .split("/")
        .sublist(0, 3)
        .join("/")
        .replaceFirst('"', "");

    // convert a to num to the power of 3 and the add 3
    var result = pow(int.parse(a!), 3) + 3;

    // get domain from url}
    var domain = url.split("/")[2];

    var link = "https://$domain$route/$result/$file";

    // return the direct link
    return link;
  }
}
