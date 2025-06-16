enum PreferenceKey {
  theme("theme"),
  locale("locale"),
  temperatureScale("temperature_scale"),
  advancedMode("advanced_mode"),
  fakeUrlBrowserPositionX("fake_url_browser_position_x"),
  fakeUrlBrowserPositionY("fake_url_browser_position_y");

  const PreferenceKey(this.key);

  final String key;

  static Set<String> get allowList => values.map((v) => v.key).toSet();
}
