/// Server url.
enum Url {
  /// Dev url.
  stage('https://api.xxx.su/'),

  /// Prod url.
  prod('https://api.xxx.su/');

  /// Url value.
  final String value;

  const Url(this.value);
}
