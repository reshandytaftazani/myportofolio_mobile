/// Base URL of the Django REST Framework backend.
///
/// Defaults to the deployed PWS backend
/// (`https://reshandy-taftazani-myportofolio.pws.cs.ui.ac.id`).
/// Override for local development with
/// `--dart-define=API_BASE_URL=http://localhost:8000` (Chrome/Web) or
/// `--dart-define=API_BASE_URL=http://10.0.2.2:8000` (Android emulator).
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://reshandy-taftazani-myportofolio.pws.cs.ui.ac.id',
);
