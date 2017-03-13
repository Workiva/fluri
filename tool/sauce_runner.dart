library fluri.tool.sauce_runner;
// PURPOSE OF SCRIPT
// run dart browser compatible unit tests on sauce labs

// Requirements to execute script
// - sauce labs credentials must be already set as environment variables

import 'dart:async';
import 'dart:convert';
import 'dart:io';

const String portServingWeb = '8080';
String sauceUserName = Platform.environment['SAUCE_USERNAME'];
String sauceAccessKey = Platform.environment['SAUCE_ACCESS_KEY'];
const String sauceUrl = 'https://saucelabs.com/rest/v1/';
const String timeForTestCompletion = '30';

// name of the html and js file to be created during the run process
const String servedFile = 'jsTestRunner';

// full path and file name to run tests on
const String fullPathToTestFile = 'test/fluri_test.dart';

String htmlTestPageContent = """
  <!DOCTYPE html>
  <html>
  <head lang=en>
      <meta charset=UTF-8>
      <title>Fluri Test Runner</title>
      <script>
      //this timeout is necessary due to an intermittent issue on
      //sauce labs where on initial page load the tests aren't run
      setTimeout(function(){
          var divElements = window.document.body.querySelectorAll('div');
          if (divElements.length == 0) {
              window.location.reload();
             }
          }, 10000);
      console._log_old = console.log;
      console.log = function(msg) {
          var div = document.createElement("div");
          div.innerHTML= msg;
          document.getElementsByTagName('body')[0].appendChild(div);
      };
      </script>
  </head>
  <body>
  </body>
  <script src=./packages/test/dart.js></script>
  <script src=$servedFile.js></script>
  </html>
  """;

String sauceRunnerFileContent = """
  @TestOn('browser')
  import 'dart:async';
  import 'dart:html';
  import 'dart:js' as js;
  import '${fullPathToTestFile.split('/').last}' as runner;
  import 'package:test/test.dart';
  Future waitForCondition(bool condition(),
    {Duration interval: const Duration(milliseconds: 5),
    Duration timeout: const Duration(seconds: 5)}) {
    Completer c = new Completer();
    DateTime now = new DateTime.now();
    new Timer.periodic(interval, (timer) {
      if (condition()) {
        timer.cancel();
        c.complete();
      }
      if (new DateTime.now().difference(now) > timeout) {
        timer.cancel();
        throw ('Conditional check did not succeed within \${timeout}');
      }
    });
    return c.future;
  }
  main() async {
    Stopwatch time = new Stopwatch();
    await time.start();
    String innerHtml;
    await new Future.delayed(new Duration(milliseconds:500));
    runner.main();
    await waitForCondition(() {
      List<Element> elementList = document.querySelectorAll('div');
      innerHtml = elementList.last.innerHtml;
      return innerHtml.contains('passed') || innerHtml.isEmpty;
    }, timeout: new Duration(seconds: $timeForTestCompletion));
    List<Element> elementList = document.querySelectorAll('div');
    await time.stop();
    RegExp exp = new RegExp(r'[\\+](\\d+)[^-]+[\\-]?(\\d+)?');
    if (innerHtml.contains('passed')) {
      Match match = exp.firstMatch(elementList.last.innerHtml);
      js.context['global_test_results'] = new js.JsObject.jsify(
            {'passed': match.group(1), 'failed': 0, 'total': match.group(1), 'duration': time.elapsed.inMilliseconds, 'tests':[]});
      } else {
      Match match = exp.firstMatch(elementList[elementList.length-2].innerHtml);
      int total = int.parse(match.group(1)) + int.parse(match.group(2));
      js.context['global_test_results'] = new js.JsObject.jsify(
            {'passed': match.group(1), 'failed': match.group(2), 'total': total.toString(), 'duration': time.elapsed.inMilliseconds, 'tests':[]});
      }
    }
  """;

// verify that a 200 response is returned from sauce and then
// return the response
Map sauceRequestHandling(String response) {
  RegExp exp = new RegExp(r'(.*)"([\d]*)"$');
  Match match = exp.firstMatch(response);
  if (!match.group(2).contains('200')) {
    String errorMsg = '\nResponse stats: ' + match.group(2);
    errorMsg += '\n' + match.group(1);
    throw new Exception(errorMsg);
  }
  return JSON.decode(match.group(1));
}

Future executeSauceTests(Process pubProcess) async {
  File htmlTestPage = new File('test/$servedFile.html');
  await htmlTestPage.writeAsString(htmlTestPageContent);

  RegExp path = new RegExp(r'(.*\/)');
  File sauceRunnerFile = new File(
      '${path.firstMatch(fullPathToTestFile).group(1)}sauce_runner.dart');
  await sauceRunnerFile.writeAsString(sauceRunnerFileContent);

  await Process.run('dart2js', [
    path.firstMatch(fullPathToTestFile).group(1) + 'sauce_runner.dart',
    '-o',
    'test/$servedFile.js'
  ]);

  // platforms to run on sauce
  List<List<String>> platforms = [
    ['Linux', 'googlechrome', '48'],
    ['Windows 7', 'firefox', '38']
  ];

  // prepares data to be sent to sauce labs
  platforms = platforms
      .map((platform) => platform.map((part) => '\"$part\"').toList())
      .toList();

  // check to see if running on travis
  String identifier = Platform.environment['TRAVIS_JOB_NUMBER'] == null
      ? ''
      : ', "tunnelIdentifier":"${Platform.environment['TRAVIS_JOB_NUMBER']}"';

  ProcessResult testPostResult = await Process.run('curl', [
    '$sauceUrl$sauceUserName/js-tests',
    '-X',
    'POST',
    '-u',
    '$sauceUserName:$sauceAccessKey',
    '-H',
    'Content-Type: application/json',
    '--data',
    '{"platforms": ${platforms.toString()},'
        '"url": "http://localhost:$portServingWeb/$servedFile.html","framework": "custom"$identifier}',
    '-w',
    '"%{http_code}"'
  ]);

  Map results = sauceRequestHandling(testPostResult.stdout);

  List testSuites = results['js tests'];
  List<Map> totalResults = [];

  for (int i = 0; i < testSuites.length; i++) {
    bool individualSuiteResult = false;
    Map individualSuiteStatus = {};
    while (!individualSuiteResult) {
      await new Future.delayed(new Duration(milliseconds: 500));
      ProcessResult test = await Process.run('curl', [
        '$sauceUrl$sauceUserName/js-tests/status',
        '-X',
        'POST',
        '-u',
        '$sauceUserName:$sauceAccessKey',
        '-H',
        'Content-Type: application/json',
        '--data',
        '{"js tests": ["${testSuites[i]}"]}',
        '-w',
        '"%{http_code}"'
      ]);
      individualSuiteStatus = sauceRequestHandling(test.stdout);
      individualSuiteResult = individualSuiteStatus['completed'];
      if (individualSuiteResult) {
        totalResults.add(individualSuiteStatus);
      }
      ;
    }
  }
  print('\nTest Results');
  totalResults.forEach((element) {
    print(element['js tests'][0]['platform'].toString() +
        element['js tests'][0]['result'].toString());
  });

  File jsTestjs = new File('test/jsTestRunner.js');
  File jsTestjsdeps = new File('test/jsTestRunner.js.deps');
  File jsTestjsmap = new File('test/jsTestRunner.js.map');

  htmlTestPage.deleteSync();
  jsTestjs.deleteSync();
  jsTestjsdeps.deleteSync();
  jsTestjsmap.deleteSync();
  sauceRunnerFile.deleteSync();

  pubProcess.kill();
}

Future waitForPubServe(Process pubProcess) async {
  File targetTestFile = new File(fullPathToTestFile);
  if (!await targetTestFile.exists()) {
    throw new Exception('Can\'t find file: ' + fullPathToTestFile);
    exit(1);
  }
  try {
    await executeSauceTests(pubProcess);
  } catch (e) {
    exit(1);
    await Process.run('killall', ['sc']);
  }
}

main() async {
  Process pubProcess = await Process.start('pub', ['serve', 'test']);

  bool testsCurrentlyRunning = false;

  var streams = [pubProcess.stdout, pubProcess.stderr];

  streams.forEach((stream) {
    stream
        .transform(new Utf8Decoder())
        .transform(new LineSplitter())
        .listen((String line) async {
      print(line);
      if (line == 'Build completed successfully' && !testsCurrentlyRunning) {
        testsCurrentlyRunning = true;
        await waitForPubServe(pubProcess);
      }
    });
  });
}
