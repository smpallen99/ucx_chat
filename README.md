# UcxChat

## Backup Database

```bash
mysqldump --add-drop-database --add-drop-table -u root --password=Gt5de3aq1 --databases ucx_chat_prod > ucx_chat.sql
```

## Restore Database

```bash
mysql -u root -pGt5de3aq1 < ucx_chat.sql
```

## Install Dependencies

### ffmpeg

```bash
rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
rpm -Uvh http://li.nux.ro/download/nux/dextop/el6/x86_64/nux-dextop-release-0-2.el6.nux.noarch.rpm
yum install ffmpeg ffmpeg-devel -y
```

### ImageMagick

```bash
yum install -y ImageMagick ImageMagick-devel
```

## Running Migrations on Dev

```
iex> Ecto.Migrator.run UcxChat.Repo, Path.join([Application.app_dir(:ucx_chat) | ~w(priv repo migrations)]), :up, all: true
```

## Updating Config When there are new entires

```elixir
alias UcxChat.{Repo, Config.FileUpload, Config}
config = Repo.all(Config) |> hd
Config.changeset(config, %{file_upload: %FileUpload{} |> Map.from_struct}) |> Repo.update
```

