# Maintainer: Edmunt Pienkowsky <roed@onet.eu>

# Based on: http://www.archlinux.org/packages/community/x86_64/grafana/
# Excluded PhantomJS library due to lack of prebuilt binaries for ARM architectures.
# You may try http://github.com/grafana/grafana-image-renderer plugin instead.

pkgname=grafana
pkgver=6.0.2
pkgrel=1
_commit_short=3f4c2e7-al
pkgdesc='Gorgeous metric viz, dashboards & editors for Graphite, InfluxDB & OpenTSDB'
url='https://grafana.com/'
arch=('x86_64' 'aarch64' 'armv7h' 'armv6h')
license=('Apache')
depends=('glibc' 'freetype2' 'fontconfig' 'gsfonts')
makedepends=('go-pie' 'npm' 'grunt-cli' 'python2')
backup=('etc/grafana.ini')
source=("$pkgname-$pkgver.tar.gz::https://github.com/grafana/grafana/archive/v$pkgver.tar.gz"
	'0001-Build-without-PhantomJS.patch'
	'0002-build-allow-to-specify-commit-hash.patch'
	'grafana.service'
	'grafana.sysusers'
	'grafana.tmpfiles'
	'nginx-grafana.conf')
sha256sums=('148f8225bd23efbdb7046e30ffad2d53a71b448f1f143e5cfe1a71c5050b4056'
            '797aafa111a994bacf06baf0763c74f0e190a8ab46aee27aab8b65f1ef05cf2d'
            'c1b0070d318df0d94420a74078ef88402cbd5c76b480872a5f6ed23f539eecb0'
            'debe84c19f1ed5a78d4fa2a664e66f04e08212803505fd9ff67b72260c98fed9'
            'bcb2d35f41dcb6a9c8240bc8fe89e78ed270a6b5307d9b46f2bf59b0c7554a2b'
            'ac3f4c95c2bedafa5d845b0ef086bbf4c943f5b8a828d92698da24f0e2a4db38'
            'e500f50fcb86859d94c9fd63084487141b7c90302a356e7e466bffcce7336014')

prepare() {
  cd $pkgname-$pkgver
  # apply patch from the source array (should be a pacman feature)
  local filename
  for filename in "${source[@]}"; do
    if [[ "$filename" =~ \.patch$ ]]; then
      msg2 "Applying patch ${filename##*/}"
      git apply "$srcdir/${filename##*/}"
    fi
  done
  # set arch linux paths
  sed -ri 's,^(\s*data\s*=).*,\1 /var/lib/grafana,' conf/defaults.ini
  sed -ri 's,^(\s*plugins\s*=).*,\1 /var/lib/grafana/plugins,' conf/defaults.ini
  sed -ri 's,^(\s*provisioning\s*=).*,\1 /var/lib/grafana/conf/provisioning,' conf/defaults.ini
  sed -ri 's,^(\s*logs\s*=).*,\1 /var/log/grafana,' conf/defaults.ini
}

build() {
  msg2 'Cache setup'
  export GOCACHE="$srcdir/cache/go"
  export YARN_CACHE_FOLDER="$srcdir/cache/yarn"
  local GOTMP="$srcdir/tmp/go"
  local GYPTMP="$srcdir/tmp/gyp"
  local NODETMP="$srcdir/tmp/node"
  mkdir -p "$GOCACHE"
  mkdir -p "$GOTMP"
  mkdir -p "$GYPTMP"
  mkdir -p "$NODETMP"
  mkdir -p "$YARN_CACHE_FOLDER"

  msg2 'GOPATH setup'
  local GOPATH="$srcdir/gopath"
  export PATH+=":$GOPATH/bin"
  mkdir -p "$GOPATH/src/github.com/grafana/"
  ln -fsrT "$srcdir/$pkgname-$pkgver/" "$GOPATH/src/github.com/grafana/grafana"
  cd "$GOPATH/src/github.com/grafana/grafana"

  msg2 'Building the backend'
  env GOPATH="$GOPATH" GOTMPDIR="$GOTMP" GOROOT_FINAL=/usr/lib/go GRAFANA_COMMIT="$_commit_short" go run build.go setup
  env GOPATH="$GOPATH" GOTMPDIR="$GOTMP" GOROOT_FINAL=/usr/lib/go GRAFANA_COMMIT="$_commit_short" go run build.go build

  msg2 'Building the frontend'
  local npm_config_prefix="$srcdir/npm"
  export PATH+=":$npm_config_prefix/bin"
  env npm_config_devdir="$GYPTMP" npm_config_prefix="$npm_config_prefix" TMPDIR="$NODETMP" npm install -g yarn
  env npm_config_devdir="$GYPTMP" npm_config_prefix="$npm_config_prefix" TMPDIR="$NODETMP" yarn install --pure-lockfile --no-progress --network-timeout=60000
  env npm_config_devdir="$GYPTMP" npm_config_prefix="$npm_config_prefix" TMPDIR="$NODETMP" npm run build release
}

package() {
  install -Dm644 grafana.tmpfiles "$pkgdir/usr/lib/tmpfiles.d/grafana.conf"
  install -Dm644 grafana.sysusers "$pkgdir/usr/lib/sysusers.d/grafana.conf"
  install -Dm644 grafana.service "$pkgdir/usr/lib/systemd/system/grafana.service"

  cd $pkgname-$pkgver

  case $CARCH in
    x86_64) PFM=amd64;;
    i686) PFM=386;;
    aarch64) PFM=arm64;;
    armv7h) PFM=arm;;
    armv6h) PFM=arm;;
  esac
  install -Dsm755 bin/linux-${PFM}/grafana-server "$pkgdir/usr/bin/grafana-server"
  install -Dsm755 bin/linux-${PFM}/grafana-cli "$pkgdir/usr/bin/grafana-cli"

  install -Dm640 conf/sample.ini "$pkgdir/etc/$pkgname.ini"
  install -Dm644 conf/defaults.ini "$pkgdir/usr/share/$pkgname/conf/defaults.ini"
  install -Dm644 "$srcdir/nginx-grafana.conf" "$pkgdir/usr/share/$pkgname/conf/nginx-grafana.conf"
  install -dm755 "$pkgdir/usr/share/grafana/"
  for i in vendor public tools; do
    cp -r "$i" "$pkgdir/usr/share/grafana/$i"
  done
}
