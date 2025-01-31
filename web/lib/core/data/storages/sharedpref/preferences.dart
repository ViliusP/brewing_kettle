enum PreferenceKey {
  theme("theme"),
  currentLocale("currentLocale");

  const PreferenceKey(this.key);

  final String key;

  static Set<String> get allowList => values.map((v) => v.key).toSet();
}
