# UcxUcc - A Team Collaboration Suite

UcxUcc is a simple but powerful team collaboration suite of applications designed to improve communications, information sharing and productivity for the businesses small and large.

This innovative suite of tools enhances business productivity with:
* An enterprise class telephone that is available anywhere your employees have an Internet connection
* Share important messaging conversations that would normally be hidden in point to point conversations with tools like SMS and Skype.
* Choose the most effect method of communications a glance at their on-line or on the phone presence.
* Upload, search and download documents, images, videos, and audio files in chat rooms and share with the rest of your team.
* Start a private conversations with direct messages
* Pin important messages for quick access for everyone
* Star important messages for your quick reference
* Track popularity of messages with message reactions and see who reacted
* Never miss an important message with an advanced notification framework that provides audible, desktop, SMS, and email notifications. Control the noise by customizing the notifications on a room by room basis.

And the bast part is that the data is safe with encrypted connections between your browser and the server. All the data is stored on your own server, note on someone else's cloud.

## Features

* Team and point-to-point messaging
* File sharing
* Sophisticated enterprise telephone that runs in your browser
** Multi line
** Hot desk to your desk phone when your away from the office
** Up to 120 programmable keys
** Desktop and Mobile support
* Point-to-point Video calls
* Highly configurable


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

