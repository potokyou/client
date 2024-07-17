FROM 3proxy/3proxy:latest

LABEL maintainer="PotokYou" 

RUN mkdir -p /opt/potok
RUN echo -e "#!/bin/bash\ntail -f /dev/null" > /opt/potok/start.sh
RUN chmod a+x /opt/potok/start.sh

ENTRYPOINT [ "/bin/sh", "/opt/potok/start.sh" ]
CMD [ "" ]