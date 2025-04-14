enum PreferenceKey {
  theme("theme"),
  locale("locale"),
  advancedMode("advanced_mode");

  const PreferenceKey(this.key);

  final String key;

  static Set<String> get allowList => values.map((v) => v.key).toSet();
}
