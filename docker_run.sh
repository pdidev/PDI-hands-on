#!/bin/bash
docker run -u="0" -v $(pwd):/home/default/ pdidevel/xenial_pdi /bin/bash /home/default/.run_as_host_user.sh \
    /bin/bash /home/default/run.sh $1 $2
