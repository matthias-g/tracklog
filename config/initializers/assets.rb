Tracklog::Application.configure do

  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
  config.assets.precompile += %w(auth.js dashboard.js logs.js tracks.js)

end