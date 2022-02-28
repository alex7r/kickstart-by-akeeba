FROM busybox

ADD kick.sh /kick.sh

ENTRYPOINT /kick.sh
