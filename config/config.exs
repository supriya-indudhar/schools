import Config

config :schools, Schools.Repo,
  database: "schools_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

  config :schools,
      ecto_repos: [Schools.Repo]
