
version = ENV['VERSION'] || '2.3.8'
arch = ENV['ARCH'] || 'amd64'
image = 'kontena/etcd'
golang_version = '1.7.5'
goarm = '7'

if arch == 'amd64'
  baseimage = 'alpine'
elsif arch == 'arm64'
  baseimage = 'aarch64/alpine'
  goarch = 'arm64'
elsif arch == 'armhf'
  goarch = 'arm'
  baseimage = 'armhf/alpine'
else
  abort "arch not supported: #{arch}"
end

task :build do
  require "tmpdir"

  Dir.mktmpdir { |tmpdir|
    sh "cp Dockerfile #{tmpdir}"

    if arch == 'amd64'
      Dir.mktmpdir { |etcd_tmp_dir|
        sh "curl -sSL --retry 5 https://github.com/coreos/etcd/releases/download/v#{version}/etcd-v#{version}-linux-amd64.tar.gz | tar -xz -C #{etcd_tmp_dir} --strip-components=1;"
        sh "cp #{etcd_tmp_dir}/etcd #{etcd_tmp_dir}/etcdctl #{tmpdir}/"
      }
    else
      Dir.chdir(File.join(Dir.pwd, 'build')) { |etcd_tmp_dir|
        cmd = [
          "/bin/bash -c '",
          "git clone https://github.com/coreos/etcd /go/src/github.com/coreos/etcd",
          "&& cd /go/src/github.com/coreos/etcd",
          "&& git checkout v#{version}",
          "&& GOARM=#{goarm} GOARCH=#{goarch} ./build",
          "&& cp -f bin/etcd* bin/etcd* /etcdbin'"
        ]
        sh "docker run -it -v #{etcd_tmp_dir}:/etcdbin golang:#{golang_version} #{cmd.join(' ')}"
        sh "cp #{etcd_tmp_dir}/etcd #{etcd_tmp_dir}/etcdctl #{tmpdir}/"
      }
    end
    Dir.chdir(tmpdir) do
      sh "sed -i.bak 's|BASEIMAGE|#{baseimage}|g' Dockerfile"
      if arch == 'amd64'
        sh "docker build --pull -t #{image}:#{version} ."
      else
        sh "docker build --pull -t #{image}-#{arch}:#{version} ."
      end
    end
  }
end

task :push => :build do
  if arch == 'amd64'
    sh "docker push #{image}:#{version}"
  else
    sh "docker push #{image}-#{arch}:#{version}"
  end
end
