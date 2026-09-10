#!/bin/sh
set -e

if [ ! -f /app/mix.exs ]; then
  echo "No Phoenix project found. Generating..."
  yes | mix phx.new /app --app books --no-html --no-gettext

  # swap Postgrex for MyXQL (MySQL)
  sed -i 's/{:postgrex, .*}/{:myxql, "~> 0.9"}/' /app/mix.exs
  sed -i '/import_deps:/d' /app/.formatter.exs
  cat >/app/lib/books/repo.ex <<'REPO'
defmodule Books.Repo do
  use Ecto.Repo,
    otp_app: :books,
    adapter: Ecto.Adapters.MyXQL
end
REPO
  sed -i 's/username: "postgres"/username: "root"/' /app/config/dev.exs
  sed -i 's/password: "postgres"/password: "books"/' /app/config/dev.exs
  sed -i 's/hostname: "localhost",/hostname: "mysql",/' /app/config/dev.exs
  sed -i 's/database: "books_dev"/database: "books_dev",\n  stacktrace: true/' /app/config/dev.exs
  sed -i 's/username: "postgres"/username: "root"/' /app/config/test.exs
  sed -i 's/password: "postgres"/password: "books"/' /app/config/test.exs
  sed -i 's/hostname: "localhost",/hostname: "mysql",/' /app/config/test.exs
  # fix NODE_PATH for Elixir 1.17 compat (replace list with Enum.join)
  sed -i 's|env: %{"NODE_PATH" => \[\([^]]*\)\]}|env: %{"NODE_PATH" => Enum.join([\1], ":")}|g' /app/config/config.exs
fi

echo "Fetching dependencies..."
mix deps.get

echo "Waiting for MySQL..."
for i in $(seq 1 60); do
  mysql -h mysql -P 3306 -u root -p"${MYSQL_ROOT_PASSWORD}" --connect-timeout=3 -e "SELECT 1" 2>/dev/null && break
  echo "  retry $i..."
  sleep 2
done

echo "Running migrations..."
mix ecto.create
mix ecto.migrate

exec mix phx.server
