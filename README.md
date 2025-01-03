# cgit+caddy+gitolite on alpine in podman

## installation

1. copy .env.example to .env
2. replace the key with your ssh key
3. run `podman compose up -d --build`
4. rerun the above command without `--build`
5. enjoy

## setup

to [clone the admin repo](https://gitolite.com/gitolite/basic-admin.html#clone-the-gitolite-admin-repo), run `git clone ssh://git@127.0.0.1:12222/gitolite-admin`.
