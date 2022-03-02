To use package you can simply run next docker-compose configuration
```yaml
version: "3.5"
services:
  kickstart:
    restart: "no"
    image: alex7r/kickstart-by-akeeba:latest
    build:
      context: ./
    volumes:
      - ./:/var/www/html
      - ./site.zip:/var/tmp/backup.zip
    environment:
      JUSERNAME: "admin"
      JUSERPASS: "qweasd"
      DB: "jdb"
      DBUSER: "jdbu"
      DBPASS: "jdbupass"
      DBPREFIX: "jos_"
      ROOTPASS: "qweasdzxcqweasdzcxc"
```
