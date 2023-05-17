class NetConnection<T> {
  final ConnectionType _response;
  final String _message;
  final T _data;
  NetConnection(this._response, this._message, this._data);

  ConnectionType get response => _response;
  String get message => _message;
  T get data => _data;
}

enum ConnectionType { wifi, data, offline }
