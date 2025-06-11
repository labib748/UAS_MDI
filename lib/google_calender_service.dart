import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;

class GoogleCalendarService {
  static final _scopes = [calendar.CalendarApi.calendarScope];

  Future<calendar.CalendarApi?> getCalendarApi() async {
    final googleSignIn = GoogleSignIn(scopes: _scopes);
    final account = await googleSignIn.signIn();
    if (account == null) return null;

    final authHeaders = await account.authHeaders;
    final authenticateClient = _GoogleAuthClient(authHeaders);
    return calendar.CalendarApi(authenticateClient);
  }

  Future<void> insertEvent(String taskTitle) async {
    final calendarApi = await getCalendarApi();
    if (calendarApi == null) return;

    final event = calendar.Event()
      ..summary = taskTitle
      ..start = calendar.EventDateTime(
        dateTime: DateTime.now().add(const Duration(minutes: 1)),
        timeZone: "GMT+7",
      )
      ..end = calendar.EventDateTime(
        dateTime: DateTime.now().add(const Duration(hours: 1)),
        timeZone: "GMT+7",
      );

    await calendarApi.events.insert(event, "primary");
  }
}

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
