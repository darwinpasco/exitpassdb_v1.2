env "local" {
  src = "file://schema/schema.sql"

  url = "postgres://exitpass:change_me@127.0.0.1:5432/exitpass_atlas_local?sslmode=disable"

  dev = "postgres://exitpass:change_me@127.0.0.1:5432/exitpass_atlas_dev?sslmode=disable"

  migration {
    dir = "file://migrations"
  }
}
env "rebuild" {
  url = "postgres://exitpass:change_me@127.0.0.1:5432/exitpass_atlas_rebuild?sslmode=disable"

  migration {
    dir = "file://migrations"
  }
}