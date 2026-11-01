/// Interface contract implemented explicitly by every concrete device class.
abstract interface class Connectable {
  void connect();

  void disconnect();
}
