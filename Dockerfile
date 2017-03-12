FROM BASEIMAGE:3.5

VOLUME /data
EXPOSE 2379 2380
COPY etcd* etcdctl* /usr/bin/
ENTRYPOINT ["/usr/bin/etcd"]
