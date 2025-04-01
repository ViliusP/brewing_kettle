enum KettleApiEndpoint {
  systemInfo("/api/v1/system-info"),
  pid("/api/v1/pid");

  const KettleApiEndpoint(this.path);
  final String path;
}
