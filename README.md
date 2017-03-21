# UcxChat

## Backup Database

```bash
mysqldump --add-drop-database --add-drop-table -u root --password=Gt5de3aq1 --databases ucx_chat_prod > ucx_chat.sql
```

## Restore Database

```bash
mysql -u root -pGt5de3aq1 < ucx_chat.sql
```

