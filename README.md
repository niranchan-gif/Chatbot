# StudyMate

**NLP-Based Intelligent Study Assistant**

StudyMate is a Flutter web application that explains educational and technical concepts, retrieves relevant records from the supplied knowledge dataset, keeps conversation context, and can generate study-focused responses. The Flutter frontend is hosted on Netlify, while the Flask API runs as a separate web service.

## Run locally

Requires Flutter 3.47.5 or compatible stable Flutter with web support enabled.

```sh
flutter pub get
flutter run -d chrome
```

To use the Flask API locally, start it in a second terminal:

```powershell
Set-Location 'backend'
python app.py
```

Then run Flutter with:

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:5000
```

## Verify and build

```sh
flutter test
flutter analyze
flutter build web --release
```

The production site is generated in `build/web`.

## NLP flow

The Flask backend normalizes the question, detects intent and topic, ranks matching dataset records, and returns a concise explanation with key points and supporting source metadata. The Flutter app uses the backend when it is reachable and keeps a local fallback response service for resilience during development.

## Netlify

Connect the repository to Netlify and use the checked-in `netlify.toml`. Its build script downloads the pinned Flutter SDK when needed, builds the web release, and publishes `build/web`. `web/_redirects` provides the SPA fallback for client-side routes.

Before the first Netlify deploy, add this environment variable in **Site configuration > Environment variables**:

```text
API_BASE_URL=https://your-public-backend.example.com
```

The value must be the public URL of the separately deployed Flask backend. Do not use `localhost` in Netlify. The build fails deliberately when the production variable is missing so the deployed site cannot silently ship with a broken API URL.

The backend can be run locally with `python backend/app.py` or deployed to a Python-capable service using `backend/requirements.txt` and the command `gunicorn --chdir backend app:app`.

## Limitations

- Retrieval is deterministic and dataset-backed; it is not a hosted large language model.
- Conversation state is kept in backend memory and is cleared when the backend restarts.
- Netlify hosts the Flutter frontend only. The Flask API must be deployed separately and configured through `API_BASE_URL`.