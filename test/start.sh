#!/usr/bin/env bash

docker run -d \
--name sshserver \
-e "ssh_key=ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQChh8FuR1iI/BINl9l2Cl/aFZVCFBXW76yks+eKQBARjXSZ6dNqB7zY74DtuVxFgNO9xkVqmWf9OF/y1XiRp/GEQ90q1KDduP4nMnpiAZcCcTW0WXaglD4rRDLNeKa9/bvEPxcP3+3VEItIkU2occ1my9AN+AuUm9+CO+I3q8auuVxCnt5igoH2cAyPCrRz+jYSpQNKlAYYdEVPIwKtX/KkHqCcjlrbCt9E+N9JSc5vQoc/zhEF9CsEHfeyLs/0gVoz5UXnLUzjxoRcqbNO2BXbJGU7t6/vuyZWggFigey5aiS3BESvot741UEbYkrYwEGlmXvpprwNwG21eDZofWHT INSECURE-Testing" \
-p 2222:22 \
anthonyneto/sshserver

docker exec -it sshserver apk add --update rsync
docker exec -it sshserver mkdir /remote_data
docker exec -it sshserver touch /remote_data/testfile

docker run -d \
--link sshserver:syncseed \
--name syncseed \
-e "ssh_user=root" \
-e "ssh_host=sshserver" \
-e "ssh_port=22" \
-e "ssh_dir=/remote_data" \
-e "ssh_key=-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAoYfBbkdYiPwSDZfZdgpf2hWVQhQV1u+spLPnikAQEY10menT
age82O+A7blcRYDTvcZFapln/Thf8tV4kafxhEPdKtSg3bj+JzJ6YgGXAnE1tFl2
oJQ+K0QyzXimvf27xD8XD9/t1RCLSJFNqHHNZsvQDfgLlJvfgjviN6vGrrlcQp7e
YoKB9nAMjwq0c/o2EqUDSpQGGHRFTyMCrV/ypB6gnI5a2wrfRPjfSUnOb0KHP84R
BfQrBB33si7P9IFaM+VF5y1M48aEXKmzTtgV2yRlO7ev77smVoIBYoHsuWoktwRE
r6Le+NVBG2JK2MBBpZl76aa8DcBttXg2aH1h0wIDAQABAoIBAHJdjN2IlC3A0wNe
zO/fXogpGdmEIQZiAYlHexsOSpIy5iiHPlFnExVBVbZ6s9Ld6I0H0WQtI0xM2toy
vD/ceYpdBj1p+E+jyAZ2neHAIGvxPcXoRa5h5zZ4/cMutlf0SzoiNTDfKiPdp9AE
WMh3cqdijHcndQON7QznWz5xV6WipXfR+e/a/20r4eqAX4vumvn5hkRPLQZOjt4Z
Om4pUPGe6vuIIkzCQj84gvECIrzNBg19Co5UaKYnbluW2jTrCxkI4Bc6wlmqujaq
HLH7HQd/SaSQOAan5XGkkk4vLy7cTMVdmUxU2+16Gkeipd0LUwTg8bmxHRjSsF2k
6JQEjAECgYEA08RsRDVrmvK2F0jHSS4LGIGBSAAvJ97lI0436+1H1kgMUV9nOURh
kpbiP0qTZos5LM1uRDlzbzUq5/2cowBRuI5z2mgkXfFnKFlncmq15aX3vBbC+G/j
iSzoskK37J/RskDqGrXKb7QkAkOUqIk4Uskj2FQbW9kHFzpZtTqTf9MCgYEAw0US
KEro7TnUw+vztRcxMGYyccae4PbU8g5hKz6MS5eTDy1Vqd4YDNr14UVMVFrgbZgI
mJrVGJeeJ9CoUox9iHoKPOz1eKbb9XJ/rdv8Xk4v9Y1Dbo18jDjSDY9ewxX8EPnC
wg+0E0vJhxXrwqG1HjECdzp/CmpAlWE7NuiDVgECgYBXub4T/4FFHhiayrZrtVw5
WaTBu/nM7YREvOljndctiIk5yGjNi2tUO5ccGvu29iPIUI3GS3prbj4I/sG9sKsp
5jFOH+g41oEicO7ushAKQ1e+HjvEiS1cLTN0bTkeGBLZYhTY3cgvwBNOsMpLixS/
Dr3/ps/ym5RZZf21mr9xqwKBgHIasnmJDINS/9lcz5RKcRvvHBsQDVc35Udsz6sN
ab3iXLTJsP0KItOgP33bmLbSQ8LGzH8gOtWcA3cQnstd/Rz683CWpvpRxsaumZ1m
pxoUZkH+wiCf3N+zdEsoNB+bgSgKSpxLwNZluuWNEa8x/zwdN2ukawgS/ppLruZv
CBABAoGBAM5bm/J0NXyEdPIbVNKr0HH2zO+GuWMUYztH0nS5rudiUfvn3hKtjDmZ
8v7Tm+cHqdk5PGUMx2iLRLUQ72IkIZt2N7jfAdMxbaTSzd3+/rBQg4pqxizDjwjS
7E1KXPZ1rHeu4zI2442Jy4Vzl1hBpeqZjioGaZbw1Gxv9QXwRCkg
-----END RSA PRIVATE KEY-----" \
-e "mnt=/data" \
-e "uid=1000" \
-e "gid=1000" \
anthonyneto/syncseed

sleep 5
docker exec -it syncseed ls -lah /data/testfile
