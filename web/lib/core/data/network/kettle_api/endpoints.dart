enum KettleApiEndpoint {
  systemInfo("/api/v1/system-info");

  const KettleApiEndpoint(this.path);
  final String path;
}
