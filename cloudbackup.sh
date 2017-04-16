#!/usr/bin/expect
spawn mount.davfs https://webdav.yandex.ru /storage/st02/cloud/Yandex.Disk
expect "Username:"
send "snakeu\r"
expect "Password:"
send "K13T;R&Oa$.sZmCXtiJ@\r"
expect eof
