use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :quilt, QuiltWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
if System.get_env("DATABASE_URL") do
  config :quilt, Quilt.Repo,
    adapter: Ecto.Adapters.Postgres,
    url: System.get_env("DATABASE_URL"),
    pool: Ecto.Adapters.SQL.Sandbox
else
  config :quilt, Quilt.Repo,
    username: "postgres",
    password: "postgres",
    database: "quilt_test",
    hostname: "localhost",
    pool: Ecto.Adapters.SQL.Sandbox
end

# Dynamically loaded modules
config :quilt, :twilio_client, Quilt.Sms.TwilioInMemory
