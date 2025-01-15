<!-- !BEGIN-NO-CGIT! -->
# Github is bad.

You should be looking at this repository on [the upstream cgit repository](https://git.estrogen.zone/cgit-oci.git) instead.
<!-- !END-NO-CGIT! -->

# cgit+caddy+gitolite on alpine in an oci runner

this is a fork of [github.com:gregjbs/docker-gitolite-cgit](https://github.com/gregjbs/docker-gitolite-cgit), with [substantial differences to upstream](#comparison-to-upstream) ([patch](https://github.com/gregjbs/docker-gitolite-cgit/compare/main...dmpmem:cgit-oci:master))

it is built for [git.estrogen.zone](https://git.estrogen.zone) and is focused around it.

## installation

1. copy .env.example to .env
2. replace the key with your ssh key
3. run `podman compose up -d --build`
4. rerun the above command without `--build`
5. enjoy

## setup

to [clone the admin repo](https://gitolite.com/gitolite/basic-admin.html#clone-the-gitolite-admin-repo), run `git clone ssh://git@127.0.0.1:12222/gitolite-admin`.

## comparison to upstream

here's a partial comparison to upstream:

- we do not use apache, [opting for caddy instead](https://github.com/gregjbs/docker-gitolite-cgit/commit/e6359a9ceb5fba89ab0d152ce6ead2da7b8afa57#diff-dd2c0eb6ea5cfc6c4bd4eac30934e2d5746747af48fef6da689e85b752f39557L1-R13)
- we have a [compose.yml](./compose.yml)
- we use [alpine's cgit & gitolite packages](https://github.com/gregjbs/docker-gitolite-cgit/commit/e6359a9ceb5fba89ab0d152ce6ead2da7b8afa57#diff-dd2c0eb6ea5cfc6c4bd4eac30934e2d5746747af48fef6da689e85b752f39557R14), instead of [building them ourselves](https://github.com/gregjbs/docker-gitolite-cgit/commit/e6359a9ceb5fba89ab0d152ce6ead2da7b8afa57#diff-dd2c0eb6ea5cfc6c4bd4eac30934e2d5746747af48fef6da689e85b752f39557L19-L35)
- we have [build](https://github.com/gregjbs/docker-gitolite-cgit/commit/e6359a9ceb5fba89ab0d152ce6ead2da7b8afa57#diff-dd2c0eb6ea5cfc6c4bd4eac30934e2d5746747af48fef6da689e85b752f39557R75) [targets](https://github.com/gregjbs/docker-gitolite-cgit/commit/e6359a9ceb5fba89ab0d152ce6ead2da7b8afa57#diff-dd2c0eb6ea5cfc6c4bd4eac30934e2d5746747af48fef6da689e85b752f39557R64) for readme formatting and [syntax highlighting](https://github.com/gregjbs/docker-gitolite-cgit/commit/e6359a9ceb5fba89ab0d152ce6ead2da7b8afa57#diff-e7a55d3d8c2b36ee7595bcfad62f883d182670c60c81d9d007e864b969c9fc9d)
- we [call it a containerfile](https://github.com/dmpmem/cgit-oci/commit/cb9c463d152c0607f2d0e2df2de043e404b7375d) because it's no longer a date between [2013](https://www.docker.com/blog/how-to-use-your-own-registry/) and [2019](https://podman.io/release/2019/01/16/podman-release-v1.0.0)
- we [do not mention docker in the repository name](#repo-title-component)

however, we:

- [try to keep a sensible cgitrc](https://github.com/gregjbs/docker-gitolite-cgit/compare/a912704a1fdc06622466c9887051e1e0b2f5d42f...dmpmem:cgit-oci:cb9c463d152c0607f2d0e2df2de043e404b7375d#diff-5045d7848aabaef72e0f1e7c65c8433ea4d0080882b3879e3f566f2b8046bb94) with minimal differences to upstream's
- [only have minimal changes](https://github.com/gregjbs/docker-gitolite-cgit/compare/a912704a1fdc06622466c9887051e1e0b2f5d42f...dmpmem:cgit-oci:cb9c463d152c0607f2d0e2df2de043e404b7375d#diff-ce6834e28260c94433e1729e6acdb9b742fc1f6a472e9d2b3e6a0aa492659460) to the SSH coniguration
- [do not modify the license](https://github.com/gregjbs/docker-gitolite-cgit/compare/a912704a1fdc06622466c9887051e1e0b2f5d42f...dmpmem:cgit-oci:cb9c463d152c0607f2d0e2df2de043e404b7375d#diff-b4668a52683f65fbc0528f6590ba160c9c64c88c302b6262c506266eb1d35180) to a more strict one, but rather only append to the authors section
